require 'vcr'

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.hook_into                               :webmock
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options                = { :record => :once }
  c.cassette_library_dir                    = 'spec/support/vcr_cassettes'
end
