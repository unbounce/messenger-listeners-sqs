class Messenger
  module Workers
    class TestWorker
      include Messenger::Workers

      def work(message)
      end

    end
  end
end
