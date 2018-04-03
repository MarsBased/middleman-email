require 'middleman-core'

require 'middleman-email/commands'
require 'middleman-email/file_sender'
require 'middleman-email/compiler'

::Middleman::Extensions.register(:email) do
  require 'middleman-email/extension'
  ::Middleman::Email::Extension
end
