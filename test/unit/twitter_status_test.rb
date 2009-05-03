require 'test_helper'

class TwitterStatusTest < ActiveSupport::TestCase
  context "a twitter status" do
    setup do          
      @status = Factory(:twitter_status)
    end
    
    should_belong_to :poster
    should_belong_to :recipient
    should_have_many :replies
    should_belong_to :birdherd_user

    should "have it's attributes updated from a Twitter::Status" do
      @twitter_status = Factory.build(:api_status)
      @status.update_from_twitter(@twitter_status)
      assert @status.text, @twitter_status.text
    end

    should "produce a reply with it's in_reply_to_status set" do
      reply = @status.reply
      assert_equal reply.in_reply_to_status_id, @status.id
    end

    should "set the reply text with its screen name" do
      reply = @status.reply
      assert_match /^@#{@status.poster.screen_name}/, reply.text
    end
  end
end
