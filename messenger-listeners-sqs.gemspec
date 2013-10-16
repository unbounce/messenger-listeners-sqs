# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'messenger/listeners/sqs_listener/version'

Gem::Specification.new do |spec|
  spec.name          = 'messenger-listeners-sqs'
  spec.version       = Messenger::Listeners::SqsListener::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["James Brennan"]
  spec.email         = ["james@jamesbrennan.ca"]
  spec.description   = 'A messenger listener that polls AWS SQS.'
  spec.summary       = 'A messenger listener that polls AWS SQS.'
  spec.homepage      = 'https://github.com/unbounce/messenger-listeners-sqs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency             'aws-sdk', '~> 1.21.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end