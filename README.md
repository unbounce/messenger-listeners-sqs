# Messenger SQS Listener

The [Messenger](https://github.com/unbounce/messenger) SQS Listener polls SQS for messages
and passes them to the active worker.

## Installation

Add this line to your application's Gemfile:

  ```Ruby
  gem 'messenger-listeners-sqs', git: 'git@github.com:unbounce/messenger-listeners-sqs.git'
  ```

And then execute:

  ```
  $ bundle
  ```

### Configuration

You must set which listener and worker the messenger will use. To create a configuration
file in your application, run `rails g messenger-listeners-sqs:install`. Set the appropriate
queue url and any other options.

  ```Ruby
  # Example config/initializers/messenger-listeners-sqs.rb

  Messenger::Listeners::SqsListener.configure do |config|
    config.queue_url = 'https://some-sqs-queue-url'
    # config.batch_size = 10
    # config.visibility_timeout = 10
    # config.wait_time = 20
  end
  ```

Your messenger must also be set to use this listener, so in `config/initializers/messenger.rb`
set `config.listener_type = :sqs`.

## Usage

See [Messenger's README](https://github.com/unbounce/messenger/blob/master/README.md).
