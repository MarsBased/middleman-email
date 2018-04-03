module Middleman
  module Email
    class FileSender

      def initialize(title, html_content, options)
        @title = title
        @email_options = options
        @html_content = html_content
      end

      def send
        from = @email_options.from_email
        to = @email_options.to_email
        file = @html_content
        subject = "#{@title} -- #{Time.now.to_i}"
        Mail.deliver do
          from     from
          to       to
          subject  "Email: #{subject}"
          body
          html_part do
            content_type 'text/html; charset=UTF-8'
            body file
          end
        end
      end
    end
  end
end
