require 'test_helper'

class TwitterDirectMessageTest < ActiveSupport::TestCase
  context "a direct message" do
    setup do
      @dm = Factory(:twitter_direct_message)
    end

    should_belong_to :sender
    should_belong_to :recipient

    # should "have it's attributes updated from a Twitter::DirectMessage" do
    #     api_dm = Factory(:api_direct_message)
    #     @dm.update_from_twitter(api_dm)
    #     assert @dm.id, api_dm.id
    #     assert @dm.text, api_dm.text
    #   end

  end
end
