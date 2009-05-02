class TwitterDirectMessagesController < ApplicationController  
  
  def index
    @account = TwitterUser.find(params[:twitter_user_id])
    @direct_messages = @account.direct_messages

    spawn do
      sync_dms(@account)
    end             

    render :update do |page|
      page.visual_effect :highlight, "direct_messages", :durations => 0.4
      page.delay(0.4) do
        page.replace "direct_messages", :partial => "direct_messages", :locals => { :statuses => @statuses, 
          :account => @account,
          :list_id => 'direct_messages'}
        end   
      end
      return
  end
end
