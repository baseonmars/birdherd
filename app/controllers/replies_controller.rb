class RepliesController < TwitterStatusesController
  layout nil, :only => :index
  def index
    @account = TwitterUser.find(params[:twitter_user_id])
    @replies = @account.replies
    
    spawn do
      sync_statuses(:replies, @account)
    end             

    render :update do |page|
      page.visual_effect :highlight, "replies", :durations => 0.4
      page.delay(0.4) do
        page.replace "replies", :partial => "replies", :locals => { :statuses => @replies, 
          :account => @account,
          :list_id => 'replies'}
        end   
    end
    return
  end

end