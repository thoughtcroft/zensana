module Zensana
  class Project
    include Zensana::Asana::Access

    def self.list
      @list ||= Zensana::Asana.inst.fetch "/projects"
    end

  end
end
