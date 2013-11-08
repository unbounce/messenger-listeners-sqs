require 'uri'
require 'aws-sdk'
require 'messenger/listeners/sqs/timer'

class Messenger
  module Listeners
    class Sqs
      include Messenger::Listeners

      attr_accessor :listening

      class << self
        attr_accessor :config
      end

      def initialize
        self.class.configure {} if self.class.config.nil?

        @sqs = AWS::SQS::Client.new
        @listening = true
      end

      def self.configure
        self.config ||= Configuration.new
        yield(config)
      end

      class Configuration
        attr_accessor :queue_url, :batch_size, :visibility_timeout, :wait_time

        def initialize
          @batch_size = 10
          @visibility_timeout = 10
          @wait_time = 20
        end
      end

      class MissingConfigurationParameterError < StandardError; end

      def listen
        # Use `begin ... end while` so that `@listening` can be set to false and we'll just
        # poll SQS once.
        begin
          messages = receive_messages
          timer = Timer.new

          timer.start

          messages.each do |message|
            break unless timer.enough_time_remaining?

            submit_message message
          end unless messages.empty?

          timer.reset
        end while @listening
      end

      private

        def receive_messages
          ensure_valid_queue_url

          response = @sqs.receive_message({ queue_url:              self.class.config.queue_url,
                                            max_number_of_messages: self.class.config.batch_size,
                                            visibility_timeout:     self.class.config.visibility_timeout,
                                            wait_time_seconds:      self.class.config.wait_time
                                          })
          response.messages
        rescue Timeout::Error
          []
        end

        def submit_message(message)
          ensure_valid_worker

          # Update this message's visibility so it doesn't expire while we're working on it.
          @sqs.change_message_visibility({ queue_url:          self.class.config.queue_url,
                                           receipt_handle:     message.receipt_handle,
                                           visibility_timeout: self.class.config.visibility_timeout
                                         })

          @worker.work message.body

          # Remove the message now that we're done.
          @sqs.delete_message({ queue_url:      self.class.config.queue_url,
                                receipt_handle: message.receipt_handle
                              })
        end

        def ensure_valid_queue_url
          uri = URI.parse self.class.config.queue_url.to_s
          unless uri.instance_of? URI::HTTPS
            raise MissingConfigurationParameterError.new 'You must set Messenger::Listeners::SqsListener.configure { |config| config.queue_url = QUEUE_URL } to a valid https URI'
          end
        end

    end
  end
end
