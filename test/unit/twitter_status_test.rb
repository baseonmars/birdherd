require 'test_helper'

class TwitterStatusTest < ActiveSupport::TestCase
  context "a twitter status" do
    setup do
      @status = Factory(:twitter_status, :id => "4")
    end

    should "have it's attributes updated from a Twitter::Status" do
      @twitter_status = Factory.build(:api_status)
      @status.update_from_twitter(@twitter_status)
      assert @status.id, @twitter_status.id
      assert @status.text, @twitter_status.text
    end
  end
end