module Middleman
  module Email
    class FileSender

      def initialize(file, options)
        @warnings = []
        @email_options = options
        @file = file
        @file_name = Pathname.new(@file).basename.to_s
        @warnings
      end

      def send
        from = @email_options.from_email
        to = @email_options.to_email
        file = html_content
        subject = "#{@file_name} -- #{Time.now.to_i}"
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

      def print_warnings
        return if @warnings.empty?

        puts "\n\e[1mWarnings structure in \e[4m#{@file_name}:\e[0m"
        @warnings.map { |warning| puts "  - #{warning}" }
      end

      private

      def html_content
        base_url = @email_options.base_url || ''
        premailer = Premailer.new(@file,
                                  base_url: base_url,
                                  warn_level: Premailer::Warnings::SAFE,
                                  adapter: :nokogiri,
                                  preserve_styles: false,
                                  remove_comments: false,
                                  remove_ids: true,
                                  'query-string' => '')
        @cosa = premailer.to_inline_css
        premailer.warnings.each do |w|
          @warnings << "#{w[:message]} (#{w[:level]}) may not render"\
            "properly in #{w[:clients]}"
        end
        premailer.to_inline_css
      end

    end
  end
end
