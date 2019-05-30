require 'spec_helper'

describe Messenger::Listeners::Sqs do

  QUEUE_URL = 'https://sqs.us-west-1.amazonaws.com/001234567890/poller-test'

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

  context '#submit_message' do
    let(:listener) { Messenger::Listeners::Sqs.new }
    let(:worker) { stub(work: :message) }
    let(:message) { double(receipt_handle: 'something') }
    let(:client) { double }

    before { listener.instance_variable_set(:@worker, worker) }
    before { Messenger::Listeners::Sqs.configure { |config| config.queue_url = QUEUE_URL } }
    before { listener.instance_variable_set(:@sqs, client) }
    before { expect(client).to receive(:delete_message).and_raise(error) }
    before { expect(worker).to_not receive(:work) }

    context 'AWS::SQS::Errors::InvalidParameterValue exception' do
      let(:error) { AWS::SQS::Errors::InvalidParameterValue }
      it 'should not raise an error' do
        expect(listener.send(:submit_message, message)).to be_nil
      end
    end

    context 'AWS::SQS::Errors::InvalidParameterValue exception' do
      let(:error) { AWS::SQS::Errors::RequestExpired }
      it 'should not raise an error' do
        expect(listener.send(:submit_message, message)).to be_nil
      end
    end

    context 'AWS::SQS::Errors::InvalidParameterValue exception' do
      let(:error) { AWS::SQS::Errors::ServiceUnavailable }
      it 'should not raise an error' do
        expect(listener.send(:submit_message, message)).to be_nil
      end
    end
  end
end
