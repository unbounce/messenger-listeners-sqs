class Messenger
  module Listeners
    class SqsListener

      attr_accessor :listening

      class << self
        attr_accessor :config
      end

      def initialize
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

      def listen
        while @listening do
          messages = receive_messages

          messages.each do |message|
            submit_message message
          end unless messages.empty?
        end
      end

      private

        def receive_messages
          response = @sqs.receive_message({ queue_url:              self.class.config.queue_url,
                                            max_number_of_messages: self.class.config.batch_size,
                                            visibility_timeout:     self.class.config.visibility_timeout,
                                            wait_time_seconds:      self.class.config.wait_time
                                          })
          response.messages
        end

        def submit_message(message)
          # Update this message's visibility so it doesn't expire while we're working on it.
          @sqs.change_message_visibility({ queue_url:          self.class.config.queue_url,
                                           receipt_handle:     message.receipt_handle,
                                           visibility_timeout: self.class.config.visibility_timeout
                                         })

          Messenger.work message.body

          # Remove the message now that we're done.
          @sqs.delete_message({ queue_url:      self.class.config.queue_url,
                                receipt_handle: message.receipt_handle
                              })
        end

    end
  end
end
