module Zensana
  class Command::Project < Zensana::Command

    desc 'find PROJECT', 'List projects that match PROJECT (by ID or NAME, regexp accepted)'
    def find(name)
      puts Zensana::Asana::Project.search(name).collect { |p| p['name'] }.sort
    end

    desc 'show PROJECT', 'Display details of PROJECT (choosing from list matching ID or NAME, regexp accepted)'
    option :tasks, type: 'boolean', aliases: '-t', default: true, desc: 'display project task summary'
    def show(project)
      candidates = Zensana::Asana::Project.search(project)

      if candidates.empty?
        say "\nNo project found matching '#{project}'", :red
      else
        result = select_project(candidates)
        candidate = Zensana::Asana::Project.new(result)
        say "\nProject attributes...", :green
        puts candidate.attributes.pretty

        if options[:tasks]
          say "Associated tasks...", :green
          puts candidate.task_list.pretty
        end
      end
    end

    desc 'convert PROJECT', 'Convert PROJECT tasks to ZenDesk tickets (exact ID or NAME required)'
    option :attachments,  type: 'boolean', aliases: '-a', default: true,  desc: 'download and upload any attachments'
    option :completed,    type: 'boolean', aliases: '-c', default: false, desc: 'include tasks that are completed'
    option :stories,      type: 'boolean', aliases: '-s', default: true,  desc: 'import stories as comments'
    option :default_tag,  type: 'string',  aliases: '-t', default: nil,   desc: 'tag to be applied to every ticket imported'
    option :default_user, type: 'string',  aliases: '-u', default: nil,   desc: 'set a default user to assign to tickets'
    option :verified,     type: 'boolean', aliases: '-v', default: true,  desc: '`false` will send email to zendesk users created'
    def convert(project)
      @asana_project = Zensana::Asana::Project.new(project)
      say <<-BANNER

This will convert the following Asana project into ZenDesk:

     id: #{@asana_project.id}
   name: #{@asana_project.name}

using options #{options}

      BANNER

      unless yes?("Do you wish to proceed?", :yellow)
        say "\nNothing else for me to do, exiting...\n", :red
        exit
      end

      # LIFO tags for recursive tagging
      #
      # `project_tag_list` holds the project tags
      # and also the tags for the current task and
      # its parent tasks which are all added to the ticket
      #
      # `section_tag_list` holds the tags for the last
      # section task which are also added to tickets
      #
      tags = [ 'zensana', 'imported' ]
      tags << options[:default_tag] if options[:default_tag]
      project_tags = [] << tags
      section_tags = []

      @asana_project.full_tasks.each do |task|
        task_to_ticket task, project_tags, section_tags
      end
      say "\n\n ---> Finished!\n\n", :green
    end

    private

    # display list of projects by name
    # and prompt for selection by index
    #
    # returns selected project_id
    #
    def select_project(array)
      return array.first['id'] if array.size == 1

      str_format   = "\n %#{array.count.to_s.size}s: %s"
      question     = set_color "\nWhich project should I use?", :yellow
      answers      = {}

      array.sort_by { |e| e['name'] }.each_with_index do |project, index|
        i = (index + 1).to_s
        answers[i] = project['id']
        question << format(str_format, i, project['name'])
      end

      puts question
      reply = ask("> ").to_s
      if answers[reply]
        answers[reply]
      else
        say "Not a valid selection, I'm out of here!", :red
        exit 1
      end
    end

    # convert and asana task into a zendesk ticket
    # calls itself recursively for subtasks
    #
    def task_to_ticket(task, project_tags, section_tags )
      if task.attributes['completed'] && !options[:completed]
        say "\nSkipping completed task: #{task.name}! ", :yellow
        return
      end

      # sections contribute their tags but nothing else
      # and the same is true of tasks already created
      if task.is_section?
        say "\nProcessing section: #{task.section_name} "
        section_tags.pop
        section_tags.push task.tags << normalize(task.section_name)
      else
        say "\nProcessing task: #{task.name} "
        project_tags.push normalize(task.tags)

        if Zensana::Zendesk::Ticket.external_id_exists?(task.id)
          say "\n >>> skip ticket creation, task already imported ", :yellow
        else
          requester = asana_to_zendesk_user(task.created_by, true)

          # create comments from the task's stories
          if options[:stories]

            comments = []
            task.stories.each do |story|
              if story['type'] == 'comment' &&
                  (author = asana_to_zendesk_user(story['created_by'], true))
                comments << Zensana::Zendesk::Comment.new(
                  :author_id  => author.id,
                  :value      => story['text'],
                  :created_at => story['created_at'],
                  :public     => true
                ).attributes
              end
            end

            # process attachments on this task
            if options[:attachments]
              download_attachments task.attachments
              if tokens = upload_attachments(task.attachments)
                comments << Zensana::Zendesk::Comment.new(
                  :author_id => requester.id,
                  :value     => 'Attachments from original Asana task',
                  :uploads   => tokens,
                  :public    => true
                ).attributes
              end
            end
          end

          # if assignee is not an agent then leave unassigned
          if (assignee_key = options[:default_user] || task.attributes['assignee'])
            unless (assignee = asana_to_zendesk_user(assignee_key, false)) &&
                (assignee.role != 'end-user')
              assignee = nil
            end
          end

          # ready to import the ticket now!
          ticket = Zensana::Zendesk::Ticket.new(
            :requester_id => requester.id,
            :external_id  => task.id,
            :subject      => task.name,
            :description  => <<-EOF,
            This is an Asana task imported using zensana @ #{Time.now}

                    Project:  #{@asana_project.name} (#{@asana_project.id})

                 Task notes:  #{task.notes}

            Task attributes:  #{task.attributes}
            EOF
            :assignee_id  => assignee ? assignee.id : '',
            :created_at   => task.created_at,
            :tags         => flatten_tags(project_tags, section_tags),
            :comments     => comments
          )
          ticket.import
        end

        # rinse and repeat for subtasks and their subtasks and ...
        # we create a new section tag list for each recursed level
        sub_section_tags = []
        task.subtasks.each do |sub|
          task_to_ticket Zensana::Asana::Task.new(sub.attributes['id']), project_tags, sub_section_tags
        end

        # this task's tags are now no longer required
        project_tags.pop
      end
    end

    # lookup up asana user on zendesk and
    # optionally create new if not exists
    #
    # return: zendesk user or nil
    #
    def asana_to_zendesk_user(spec, create)
      key = spec.is_a?(Hash) ? spec['id'] : spec
      asana   = Zensana::Asana::User.new(key)
      zendesk = Zensana::Zendesk::User.new
      zendesk.find(asana.email)
    rescue NotFound
      if create
        zendesk.create(
          :email => asana.email,
          :name  => asana.name,
          :verified => options[:verified]
        )
        zendesk
      else
        nil
      end
    else
      zendesk
    end

    # download the attachments to the local file system
    # and retry a few times because internet
    # the download process is restartable (idempotent)
    #
    def download_attachments(attachments)
      return if attachments.nil? || attachments.empty?
      say "\n >>> downloading attachments "

      attachments.each do |attachment|
        tries = 3
        begin
          attachment.download
          print '.'
        rescue
          retry unless (tries-= 1).zero?
          raise
        end
      end
    end

    # upload all of the attachments from the local file system
    # and retry a few times because internet
    #
    # return: array of tokens
    #
    def upload_attachments(attachments)
      return if attachments.nil? || attachments.empty?
      say "\n >>> uploading attachments "

      [].tap do |tokens|
        attachments.each do |attachment|
          tries = 3
          begin
            uploader = Zensana::Zendesk::Attachment.new
            tokens << uploader.upload(attachment.full_path)['token']
            print '.'
          rescue
            retry unless (tries-= 1).zero?
            raise
          end
        end
      end
    end

    # take multiple arrays and flatten them
    #
    # return: single array of unique tags
    #
    def flatten_tags(*args)
      tags = []
      args.each { |a| tags << a }
      tags.flatten.uniq
    end

    def normalize(thing)
      case
      when thing.is_a?(String)
        normalize_it thing
      when thing.is_a?(Array)
        thing.map { |a| normalize a }
      else
        raise ArgumentError, "I don't know how to normalize instances of #{thing.class}"
      end
    end

    def normalize_it(thing)
      thing.gsub(/(\/| |-)+/,'_').downcase
    end
  end
end
