require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase      
  
  context "a twitter user2" do
    setup do
      @twitter_user = Factory(:twitter_user)
    end              
    
    should "have a friends timeline" do
      status = Factory :twitter_status
      TwitterStatus.expects(:merge_all).returns([status])
      Twitter::Base.any_instance.expects(:friends_timeline).returns([status])
      assert_equal [status], @twitter_user.friends_timeline  
    end
    
    should "have sent direct messages" do
      message = Factory :twitter_direct_message
      TwitterUser.any_instance.expects(:direct_messages_sent).returns([message])
      assert_equal [message], @twitter_user.direct_messages_sent
    end
    
    should "have recieved direct message" do
      message = Factory :twitter_direct_message
      TwitterUser.any_instance.expects(:direct_messages_received).returns([message])
      assert_equal [message], @twitter_user.direct_messages_received
    end
    
    should "have a history of sent statuses and sent direct messages" do                                                                               
      status               = Factory :twitter_status, :sender => @account
      message_sent         = Factory :twitter_direct_message, :sender => @account
      api_status           = Factory :api_status, status.attributes
      api_message_sent     = Factory :api_message, message_sent.attributes         
                                                                                                    
      Twitter::Base.any_instance.expects(:user_timeline).returns([api_status]) 
      Twitter::Base.any_instance.expects(:direct_messages_sent).returns([api_message_sent])
      Twitter::Base.any_instance.expects(:direct_messages).never   
                            
      history = [message_sent,status]
      user_history = @twitter_user.history
      assert history.all? {|item| user_history.include?(item)}
    end                                                        
    
    should "should have a sorted history" do                                                                               
      earlier_status     = Factory :twitter_status, :created_at => 5.minutes.ago
      later_status       = Factory :twitter_status, :created_at => 1.minutes.ago
      message            = Factory :twitter_direct_message, :created_at => 3.minutes.ago
      
      earlier_api_status = Factory :api_status, earlier_status.attributes
      later_api_status   = Factory :api_status, later_status.attributes      
      api_message        = Factory :api_message, message.attributes

      Twitter::Base.any_instance.expects(:user_timeline).returns([earlier_api_status, later_api_status]) 
      Twitter::Base.any_instance.expects(:direct_messages_sent).returns([api_message])
                
      history = [later_status, message, earlier_status]
      assert_equal history, @twitter_user.history                                                                     
    end    

    should "have mixed sent and recieved direct messages" do
      messages = (0..1).collect { Factory :api_status }
      TwitterUser.any_instance.expects(:direct_messages).returns(messages)
      assert_equal messages, @twitter_user.direct_messages
    end   
    
    should "verify it's credentials" do                               
      api_user = Factory(:api_user, :screen_name => 'charlie')
      Twitter::Base.any_instance.expects(:verify_credentials).returns(api_user)
      @twitter_user = @twitter_user.verify_credentials                                   
      assert_equal api_user.screen_name, @twitter_user.screen_name
    end
    
    should "get a verifed user from a_token" do
     api_user = Factory :api_user
     Twitter::Base.any_instance.expects(:verify_credentials).returns(api_user)
     @twitter_user = TwitterUser.get_verified_user('a_token','a_secret')
     assert_equal api_user.screen_name, @twitter_user.screen_name 
     assert_equal 'a_token', @twitter_user.access_token
    end                                                           
                    
    should "have direct messages limited to 30" do
      Twitter::Base.any_instance.expects(:direct_messages).with(:count => 30)
      @twitter_user.direct_messages
    end
    
    should "limit direct messages to 30" do                        
      sent = (0..16).map { Factory :twitter_direct_message, :sender => @twitter_user }
      received = (0..16).map {Factory :twitter_direct_message, :recipient => @twitter_user}
      TwitterUser.any_instance.expects(:direct_messages_sent).returns(sent)
      TwitterUser.any_instance.expects(:direct_messages_recieved).returns(received)
      assert_equal 30, @twitter_user.direct_messages.length
    end  
    
    should "has many mentions" do
      assert @twitter_user.respond_to?(:mentions)
    end
  end
  
  # Replace this with your real tests.
  context "a twitter user" do
    setup do
      @twitter_user = Factory(:twitter_user)
    end

    should_have_and_belong_to_many :users
    should_have_many :statuses

    should "update its attributes from an api user" do
      api_user = Factory.build(:api_user)
      
      @twitter_user = TwitterUser.merge(api_user)
      api_user.each do |k,v|
        assert_equal v, @twitter_user[k]
      end
    end
    
    should "keep track of the last id it pulled for timeline, reply and dm's" do
      assert_respond_to @twitter_user, :friends_timeline_last_id
      assert_respond_to @twitter_user, :replies_last_id
      assert_respond_to @twitter_user, :sent_dms_last_id
      assert_respond_to @twitter_user, :recieved_dms_last_id
    end

    context "owned by a user" do
      setup do
        @user = Factory(:user)
        @twitter_user.users << @user
      end

      should "agree that it is owned by a user" do
        assert @twitter_user.owned_by?(@user)
      end

      should "return false if owned by no one" do
        new_user = Factory(:twitter_user)
        assert !new_user.owned_by?(@user)
      end
    end

    context "with 1 sent and 1 recieved direct message" do
      setup do
        @other_user = Factory(:twitter_user)
        @sent_message = Factory(:twitter_direct_message, :sender => @twitter_user, :recipient => @other_user)
        @recieved_message = Factory(:twitter_direct_message, :sender => @other_user, :recipient => @twitter_user)
        @twitter_user.reload
      end

      should "have limit sent direct message to 30" do
        Twitter::Base.any_instance.expects(:direct_messages_sent).with(:count => 30)
        @twitter_user.direct_messages_sent
      end

      should "have limit recieved direct message to 30" do
        Twitter::Base.any_instance.expects(:direct_messages).with(:count => 30)
        @twitter_user.direct_messages_recieved
      end

      should "have two direct messages" do
        Twitter::Base.any_instance.expects(:direct_messages).returns([Factory.build(:api_message)])
        Twitter::Base.any_instance.expects(:direct_messages_sent).returns([Factory.build(:api_message)])
        assert_equal @twitter_user.direct_messages.length, 2
      end
    end
      
  end
end
