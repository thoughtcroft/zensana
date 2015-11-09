module Zensana
  module Helpers

    INVALID_SELECTION_MSG = "\n  --> That's not a valid selection, I'm out of here!\n\n"
    EXIT_SELECTION_MSG    = "\n --> OK, nothing else for me to do here!\n\n"

    # provide a list of choices to the user and ask them to select one or more
    # list is an array of hashes like this:
    #   {
    #     :key   => 'value to be returned if selected',
    #     :value'=> 'value to be displayed as choice'
    #   }
    def ask_which_item(items, prompt, mode=:single)
      return Array(get_hash(items.first, :key)) if items.size == 1
      str_format = "\n %#{items.count.to_s.size}s: %s"
      prompt << "\n > Enter a single selection, "
      prompt << "multiple selections separated by ',', 'A' for all, " if mode == :multiple
      prompt << "'Q' or nothing to quit"
      question   = set_color prompt, :yellow
      answers    = {}

      items.each_with_index do |item, index|
        i = (index + 1).to_s
        answers[i] = get_hash(item, :key)
        question << format(str_format, i, get_hash(item, :value))
      end

      say question
      reply = ask(" >", :yellow).to_s
      replies = reply.split(',')
      if reply.empty? || reply.upcase == 'Q'
        say EXIT_SELECTION_MSG, :green
        exit 0
      elsif answers[reply]
        answers.values_at(reply)
      elsif mode == :single
        say INVALID_SELECTION_MSG, :red
        exit 1
      elsif mode == :multiple && reply.upcase == 'A'
        answers.values
      elsif mode == :multiple && !replies.empty?
        selected_items = answers.values_at(*replies)
        if selected_items.include?(nil)
          say INVALID_SELECTION_MSG, :red
          exit 1
        end
        selected_items
      end
    end

    def get_hash(hash, key)
      hash[key.to_sym] || hash [key.to_s]
    end
  end
end
