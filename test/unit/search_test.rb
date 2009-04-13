require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  
  should_belong_to :twitter_user

  context "with statuses tagged to match" do
    setup do 
      @status = Factory(:twitter_status, :tag_list => 'chips, bacon, eggs')
      @search = Factory(:search, :tag_list => 'chips')
    end
    
    should "get a status with at least one matching tag" do
      assert_contains @search.statuses, @status
    end
    
    should "get a status with all matching tags" do
      @search = Factory(:search, :tag_list => 'chips, eggs, bacon')
      assert_contains @search.statuses, @status
    end
    
    should "not get statuses if there are no matches" do
      @search = Factory(:search, :tag_list => 'not, here')
      assert_does_not_contain @search.statuses, @status
    end
  end
end
