module XssTerminate
  module Sanitizers
    class Text
      # Discards anything that looks like tags.
      # A tag starts with '<' and is followed by '/' or an alphabet
      # Examples:
      # a<b<c       a<b<c
      # a<<         a<<
      # a<>         a<>        (Since <> is not a tag)
      # a<<>        a<<>       (Since <> is not a tag)
      # a<<>>       a<<>>      (Since <> and <<>> are not tags)
      # a</b>       a
      # a</b        a</b
      # <script>alert("hi")</script>    alert("hi")
      # @param unsanitize [String] the String to sanitize
      # @param options [unused] not used
      # @return [String] sanitized text
      def sanitize(unsanitized, options = nil)
        texts = [""]
        i = 0
        while i < unsanitized.length
          c = unsanitized[i]
          case c
          when '<'
            texts.push(c)
          when '>'
            batch = texts.size > 1 ? texts.pop : nil
            unless is_tag?(batch)
              # batch is not a tag
              texts.last << batch if batch
              texts.last << c
            end
          else
            texts.last << c
          end

          i += 1
        end
        texts.inject("") do |text ,l|
          text << l
        end
      end

      # Returns true if `batch` looks like an XML opening or closing tag
      def is_tag?(batch)
        return false if batch.nil?

        # Check second character in the batch. The first is <.
        # If second character is a letter or /, then it looks like a tag
        test_ch = batch[1]
        return !test_ch.nil? && !test_ch.match(/[\/|[[:alpha:]]]/).nil?
      end
    end
  end
end
