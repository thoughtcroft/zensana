require 'csv'

module Zensana
  class Command::View < Zensana::Command

    desc 'export VIEW', 'Export Zendesk VIEW using the predetermined fields'
    def export(id)
      view = Zensana::Zendesk::View.new
      view.find(id)

      unless yes?("This will export the tickets in the view called '#{view.title}' as a CSV. Proceed?", :yellow)
        say "\nNothing else for me to do, exiting...\n", :red
        exit
      end

      tickets = view.tickets

      csv_file = "zendesk_export_view_#{id}_#{Time.now.strftime('%Y_%m_%d_%H%M')}.csv"
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
