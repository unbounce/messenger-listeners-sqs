require 'messenger'
require 'simplecov'

SimpleCov.start do
  add_group 'Libraries', 'lib/'
  add_filter '/spec/'
end

require 'messenger/listeners/sqs'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
