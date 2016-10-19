module Middleman
  module Email
    class Email

      DEFAULT_SUBJECT = 'MIDDLEMAN PREMAILER EMAIL'

      def initialize(body:, from:, to:, subject: DEFAULT_SUBECT )
        @body = body
        @from = from
        @to = to
        @subject = subject
      end

      def send
        Mail.deliver do
          from     from
          to       to
          subject  subject
          html_part do
            content_type 'text/html; charset=UTF-8'
            body body
          end
        end
      end

      private

      attr_reader :body, :from, :to, :subject




    end
  end
end
