module Middleman
  module Email
    class Compiler

      attr_reader :file_name

      def initialize(file, options)
        @warnings = []
        @email_options = options
        @file = file
        @file_name = Pathname.new(@file).basename.to_s
        @warnings
      end

      def compile
        base_url = @email_options.base_url || ''
        premailer = Premailer.new(@file,
                                  base_url: base_url,
                                  warn_level: Premailer::Warnings::SAFE,
                                  adapter: :nokogiri,
                                  preserve_styles: false,
                                  remove_comments: false,
                                  remove_ids: true,
                                  'query-string' => '')
        premailer.warnings.each do |w|
          @warnings << "#{w[:message]} (#{w[:level]}) may not render"\
            "properly in #{w[:clients]}"
        end
        premailer.to_inline_css
      end

      def print_warnings
        return if @warnings.empty?

        puts "\n\e[1mWarnings structure in \e[4m#{@file_name}:\e[0m"
        @warnings.map { |warning| puts "  - #{warning}" }
      end

    end
  end
end
