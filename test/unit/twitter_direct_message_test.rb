require 'test_helper'

class TwitterDirectMessageTest < ActiveSupport::TestCase
  context "a direct message" do
    setup do
      @message = Factory(:twitter_direct_message)
    end

    should_belong_to :sender
    should_belong_to :recipient
                                 
    should "have no replies" do
      assert @message.replies.empty?
    end

    context "that has been merged" do
      setup do
        @api_message = Factory.build :api_message, :text => "lorum ipsum", :created_at => Time.new
        @saved_message = Factory :twitter_direct_message, :id => @api_message.id
        TwitterDirectMessage.expects(:find_or_initialize_by_id).returns(@saved_message)
        @merged_message = TwitterDirectMessage.merge(@api_message)
      end                                 

      should "have text from api_message" do
        assert_equal @api_message.text, @merged_message.text
      end  

      should "have id from api_message" do
        assert_equal @api_message.id, @merged_message.id
      end   

      should "have created at date from api_message" do
        assert_equal    @api_message.created_at, @merged_message.created_at 
        assert_not_nil  @merged_message.created_at
      end               
    end
    
    should "handle merging with nil" do
      message = TwitterDirectMessage.merge(nil)
      assert_nil message, "message is not nil"
      assert_nil $!, "exception thrown"
    end
    
    should "return an empty array when merge_all with nil" do
      message = TwitterDirectMessage.merge_all nil
      assert_equal [], message
    end
      

  end
end
                                         