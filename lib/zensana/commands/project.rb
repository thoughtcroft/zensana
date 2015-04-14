require 'pry'

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
    option :default_user, type: 'string',  aliases: '-u', default: nil,   desc: 'set a default user to assign to tickets'
    option :followers,    type: 'boolean', aliases: '-f', default: false, desc: 'add followers of tasks to tickets'
    option :stories,      type: 'boolean', aliases: '-s', default: true,  desc: 'import stories as comments'
    option :verified,     type: 'boolean', aliases: '-v', default: true,  desc: '`false` will send email to zendesk users created'
    def convert(project)
      asana_project = Zensana::Asana::Project.new(project)
      say <<-BANNER

This will convert the following Asana project into ZenDesk:

     id: #{asana_project.id}
   name: #{asana_project.name}

using options #{options}

        BANNER

      unless yes?("Do you wish to proceed?", :yellow)
        say "Nothing else for me to do, exiting...", :red
        exit
      end

      # LIFO tags for recursive tagging
      tags = [ asana_project.tags << 'asana' ]

      asana_project.full_tasks.each do |task|
        task_to_ticket tasks, tags
      end
      say "\nFinished!", :green
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
    # calls itself recursively for sub-tasks
    #
    def task_to_ticket(task, tag_list=[] )
      if task['completed'] && !options[:completed]
        say "Skipping completed task #{task.name}!", :yellow
        return
      end
      say "Processing task #{task.name} ..."

      # add task tags to the list
      tags = task.tags
      tags << task.section_name if task.is_section?
      tag_list.push tags

      # sections contribute their tags and any
      # sub-tasks but no other processing by design
      unless task.is_section?
        requester = asana_to_zendesk_user(task.created_by, true)

        # create comments from the task's stories
        if options[:stories]

          comments = [].tap do |c|
            task.stories.each do |story|
              if story[:type] == 'comment' &&
                  (author = asana_to_zendesk_user(story[:created_by], true))
                c << Zensana::Zendesk::Comment.new(
                  :author_id  => author.id,
                  :value      => story[:text],
                  :created_at => story[:created_at],
                  :public     => true
                ).attributes
              end
            end
          end

          # process attachments on this task
          if options[:attachments]

            say " > downloading attachments "
            download_attachments task.attachments

            say " > uploading attachments "
            tokens = upload_attachments task.attachments

            comments << Zensana::Zendesk::Comment.new(
              :author_id   => requester.id,
              :value       => 'Attachments from original Asana task',
              :attachments => tokens,
              :public      => true
            ).attributes
          end
        end

        # if assignee is not an agent then leave unassigned
        assignee_key = options[:default_user] || task.assignee
        unless (assignee = asana_to_zendesk_user(assignee_key, false)) &&
            (assignee.role != 'end-user')
          assignee = nil
        end

        # ready to import the ticket now!
        ticket = Zensana::Zendesk::Ticket.new(
          :requester_id => requester.id,
          :external_id  => task.id,
          :subject      => task.name,
          :description  => <<-EOF,
            Asana task imported #{now} using attributes:

          #{task.attributes}
          EOF
          :assignee_id  => assignee ? assignee.id : '',
          :created_at   => task.created_at,
          :tags         => tags.flatten.uniq,
          :comments     => comments
        )
        # ticket.import
        binding.pry
      end

      # rinse and repeat for sub-tasks and their sub-tasks and ...
      say "... analysing sub-tasks ..."
      task.sub_tasks.each do |sub|
        task_to_ticket Zensana::Asana::Task.new(sub['id']), tag_list
      end

      # no longer need this task's tags
      tag_list.pop
    end

    # lookup up asana user on zendesk and
    # optionally create new if not exists
    #
    # return: zendesk user or nil
    #
    def asana_to_zendesk_user(spec, create)
      asana   = Zensana::Asana::User.new(spec)
      zendesk = Zensana::Zendesk::User.new
      zendesk.find(asana.email)
    rescue NotFound
      if create?
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
      attachments.each do |attachment|
        tries = 3
        begin
          Zensana::Asana::Attachment.new(attachment['id']).download
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
      [].tap do |tokens|
        attachments.each do |attachment|
          tries = 3
          begin
            tokens << Zensana::Zendesk::Attachment.new.upload(attachment.full_path)
            print '.'
          rescue
            retry unless (tries-= 1).zero?
            raise
          end
        end
      end
    end
  end
end
