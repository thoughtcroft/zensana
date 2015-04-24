module Zensana
  class Zendesk
    class Group
      include Zensana::Zendesk::Access

      class << self

        def list
          @@list ||= Zensana::Zendesk.inst.fetch('/groups.json')['groups']
        end

        def search(spec)
          list.select { |g| g.to_s =~ %r{#{spec}} }
        rescue RegexpError
          raise BadSearch, "'#{spec}' is not a valid regular expression"
        end

      end

    end
  end
end
