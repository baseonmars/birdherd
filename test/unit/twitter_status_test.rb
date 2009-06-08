require 'test_helper'

class TwitterStatusTest < ActiveSupport::TestCase
  context "a twitter status" do
    setup do          
      @status = Factory(:twitter_status)
    end

    should_belong_to :poster
    should_belong_to :recipient
    should_belong_to :birdherd_user

    context "that has been merged" do
      setup do                                             
        @api_status = Factory.build :api_status, :text => "lorum ipsum", :created_at => Time.new
        @saved_status = Factory :twitter_status, :id => @api_status.id
        TwitterStatus.expects(:find_or_initialize_by_id).returns(@saved_status)
        @merged_status = TwitterStatus.merge(@api_status)
      end                                              

      should "have text from api_status" do
        assert_equal @api_status.text, @merged_status.text
      end  

      should "have id from api_status" do
        assert_equal @api_status.id, @merged_status.id
      end   

      should "have created at date from api_status" do
        assert_equal    @api_status.created_at, @merged_status.created_at 
        assert_not_nil  @merged_status.created_at
      end               
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

  should "set a limit of 30 statuses when getting the friends timeline" do
    account = Factory :twitter_user
    Twitter::Base.any_instance.expects(:friends_timeline).with(:limit => 30).returns([Factory.build :api_status])
    account.friends_timeline
  end

end
