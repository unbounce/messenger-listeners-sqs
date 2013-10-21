class Messenger
  module Listeners
    class Sqs
      class Timer

        # Set neccessary timestamps before a batch of messages is processed.
        #
        def start
          now = Time.now

          @started_at = now
          @finished_last_message_at = now
          @longest_elapsed_time = 0
        end

        # Reset the timestamps for the next batch of messages.
        #
        def reset
          @started_at = nil
          @finished_last_message_at = nil
          @longest_elapsed_time = nil
        end

        # Determine if there is enough time remaining in the `visibility_timeout` to
        # process the next message.
        #
        def enough_time_remaining?
          now = Time.now

          current_elapsed_time = now - @finished_last_message_at
          @longest_elapsed_time = (current_elapsed_time > @longest_elapsed_time) ? current_elapsed_time : @longest_elapsed_time

          # Setup for next time
          @finished_last_message_at = now

          time_remaining = Messenger::Listeners::Sqs.config.visibility_timeout - (now - @started_at)
          time_remaining > @longest_elapsed_time
        end

      end
    end
  end
end
