require 'middleman-core'

require 'middleman-email/commands'
require 'middleman-email/file_sender'

::Middleman::Extensions.register(:email) do
  require 'middleman-email/extension'
  ::Middleman::Email::Extension
end
