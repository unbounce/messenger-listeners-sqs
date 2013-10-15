require 'rails/generators'

module Messenger
  module Listeners
    module SqsListener
      module Generators
        class InstallGenerator < Rails::Generators::Base
          desc "Installs Messenger's initializer"

          def self.source_root
            File.expand_path('../templates', __FILE__)
          end

          def copy_initializer
            template 'messenger.rb.erb', 'config/initializers/messenger.rb'
          end

        end
      end
    end
  end
end
