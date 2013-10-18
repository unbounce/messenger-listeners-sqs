require 'spec_helper'

describe Messenger::Listeners::SqsListener do

  describe 'configure' do
    it 'should require a block' do
      expect { Messenger.configure }.to raise_error LocalJumpError
    end
  end

end
