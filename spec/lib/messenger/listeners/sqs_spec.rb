require 'spec_helper'

describe Messenger::Listeners::Sqs do

  QUEUE_URL = 'https://sqs.us-west-1.amazonaws.com/002682819933/poller-test'

  describe 'configure' do
    it 'should require a block' do
      expect { Messenger::Listeners::Sqs.configure }.to raise_error LocalJumpError
    end
  end

  describe 'listen' do
    let(:listener) { Messenger::Listeners::Sqs.new }

    before do
      # Poll only once
      listener.listening = false
    end

    context 'with queue url' do
      before do
        Messenger::Listeners::Sqs.configure { |config| config.queue_url = QUEUE_URL }
        listener.worker = Messenger::Workers::TestWorker.new
      end

      it 'should receive SQS messages' do
        listener.worker.should_receive :work

        VCR.use_cassette('SQS listen import message') do
          listener.listen
        end
      end
    end

    context 'without valid worker' do
      before do
        Messenger::Listeners::Sqs.configure { |config| config.queue_url = QUEUE_URL }
      end

      it 'should raise error' do
        VCR.use_cassette('SQS listen import message') do
          expect { listener.worker = Object.new and listener.listen }.to raise_error NotImplementedError
        end
      end
    end

    context 'without queue url' do
      before do
        Messenger::Listeners::Sqs.configure { |config| config.queue_url = nil }
        listener.worker = Messenger::Workers::TestWorker.new
      end

      it 'should raise error' do
        expect { listener.listen }.to raise_error
      end
    end

  end

end
