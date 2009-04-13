require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :twitter_users
end
