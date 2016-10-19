module Middleman
  module Email
    class Premailer

        DEFAULT_OPTIONS = {
          warn_level: Premailer::Warnings::SAFE,
          adapter: :nokogiri,
          preserve_styles: false,
          remove_comments: false,
          remove_ids: true,
          'query-string' => ''
        }

        def self.compile(file_path, options = DEFAULT_OPTIONS)
          premailer = Premailer.new(file_path, options)
          premailer.to_inline_css
        end

    end
  end
end
