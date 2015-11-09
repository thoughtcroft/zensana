require 'csv'

module Zensana
  class Command::View < Zensana::Command
    include Zensana::Helpers

    desc 'export', 'Export Zendesk View using the predetermined fields'
    option :view, type: 'string', aliases: '-v', default: nil, desc: 'specific view number to export'
    def export
      view = Zensana::Zendesk::View.new

      if view_id = options[:view]
        view.find(view_id)
        unless yes?("\nThis will export the tickets in the Zendesk View called '#{view.title}' as a CSV. Proceed?", :yellow)
          say EXIT_SELECTION_MSG, :red
          exit
        end
      else
        views = view.list.map { |v| { :key => v['id'], :value => v['title'] } }.sort_by { |i| i[:value] }
        view_id = ask_which_item(views, "\nChoose the Zendesk View you wish to export", :single).first
        view.find(view_id)
      end

      tickets = view.tickets

      csv_file = "zendesk_export_view_#{view_id}_#{Time.now.strftime('%Y_%m_%d_%H%M')}.csv"
      Dir.chdir file_dir = File.join(Dir.home, 'Downloads')

      CSV.open(csv_file, 'w') do |output|
        output << %w(Id Status Subject Component Description Requester RequestDate SolvedDate Duration)
        tickets.each do |ticket|
          output.puts transform_ticket(ticket)
        end
      end

      say "\nYour view has been successfully exported to '#{File.join(file_dir, csv_file)}'", :green
    end

    private

    # create an array of fields matching the csv header
    def transform_ticket(ticket)
      fields = []
      fields << ticket['id']
      fields << ticket['status']
      fields << ticket['subject']
      fields << get_component(ticket['custom_fields'])
      fields << clean_text(ticket['description'], 5)
      fields << get_user_name(ticket['requester_id'])
      created = Date.parse(ticket['created_at'])
      updated = Date.parse(ticket['updated_at'])
      fields << created.to_s
      fields << updated.to_s
      fields << (updated - created).to_i
    end

    def get_user_name(id)
      user = Zendesk::User.new.find(id)
      user['name'] || user['email']
    end

    def get_component(fields)
      get_custom_field(fields, '24375555').split('_').last
    end

    def get_custom_field(fields, id)
      fields.each do |field|
        return field['value'] if field['id'].to_s == id.to_s
      end
    end

    def clean_text(text, max_lines)
      ''.tap do |result|
        text.split("\n").each do |line|
          next if line.empty? || ignore_line?(line)
          result << line << ' '
          break if (max_lines -= 1).zero?
        end
      end
    end

    def ignore_line?(line)
      ignore_list.inject(false) do |result, matcher|
        result || line.include?(matcher)
      end
    end

    def ignore_list
      [
        'Original Message', 'From:', 'Sent:',
        'To:', 'Cc:', 'Subject:',
        '---', '___', 'Hi ', 'Hi,'
      ]
    end

  end
end
