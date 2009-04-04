require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase

  context "a friendship" do
    
    should_belong_to :twitter_user, :friend
  end
end
