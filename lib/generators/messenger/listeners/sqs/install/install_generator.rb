require 'rails/generators'

class Messenger
  module Listeners
    class Sqs
      module Generators
        class InstallGenerator < Rails::Generators::Base
          desc "Installs Messenger's initializer"

          def self.source_root
            File.expand_path('../templates', __FILE__)
          end

          def copy_initializer
            template 'messenger-listeners-sqs.rb.erb', 'config/initializers/messenger-listeners-sqs.rb'
          end

        end
      end
    end
  end
end
