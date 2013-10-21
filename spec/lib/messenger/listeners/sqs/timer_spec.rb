require 'spec_helper'

describe Messenger::Listeners::Sqs::Timer do

  describe 'enough_time_remaining?' do
    let(:timer) { Messenger::Listeners::Sqs::Timer.new }

    before do
      Messenger::Listeners::Sqs.configure do |config|
        config.visibility_timeout = 10
      end
    end

    it 'should return true if timeout has not passed' do
      timer.start

      9.times do
        timer.enough_time_remaining?.should be_true
        sleep 1
      end

    end

    it 'should return false if timeout has not passed' do
      timer.start
      sleep 10
      timer.enough_time_remaining?.should be_false
    end

  end

end
