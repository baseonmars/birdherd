class TwitterStatusesController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :reply]

  def index
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @statuses = @twitter_user.statuses
  end

  def new
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @status = @twitter_user.statuses.new
  end

  def create
    begin
      twitter_user = @current_user.twitter_users.find(params[:twitter_user_id])
    rescue
      render :text => "You are not permitted to post statuses as an account you don't own", :status => 401
      return
    end

    begin
      raise "can't post a blank message" if params[:twitter_status].nil?
      status = twitter_user.statuses.new(params[:twitter_status])
      raise "can't post dm's to self" if status.text =~ /^d #{twitter_user.screen_name}\s/
      
      post_update(twitter_user, status)
      flash[:notice] = "Posted!"
      redirect_to user_twitter_user_url(twitter_user) and return
    rescue
      flash[:warning] = "could not post status: #{$!}"
      redirect_to user_twitter_user_url(twitter_user) and return
    end
  end

  def show
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @status = TwitterStatus.find(params[:id])
  end

  def reply
    @status = TwitterStatus.find(params[:status_id])
    begin
      @twitter_user = @current_user.twitter_users.find(params[:account_id])
      @reply = @status.reply
    rescue
      flash[:notice] = "You don't have the right to reply"
      redirect_to '/'
      return
    end
  end
  
  private
  def post_update(account, status)
    if status.text =~ /^d \w+\s/
      puts 'direct_message'
      user, text = status.text.scan(/^d (\w+) (.*)/).flatten
      response = twitter_api(account).direct_message_create(user, text)
      dm = @current_user.direct_messages.build
      dm.id = response.id
      dm.update_from_twitter(response)
      dm.sender = update_twitter_user(response.sender)
      dm.recipient = update_twitter_user(response.recipient)
      dm.save
      return dm
    else      
      puts 'status'
      response = twitter_api(account).update( status.text, :in_reply_to_status_id => status.in_reply_to_status_id, :source => 'birdherd' )
      status = @current_user.statuses.build
      status.id = response.id
      status.update_from_twitter(response)
      status.poster = update_twitter_user(response.user)
      status.save
      return status
    end
  end

end
