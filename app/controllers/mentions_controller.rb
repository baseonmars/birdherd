class MentionsController < TwitterStatusesController
  layout nil, :only => :index
  def index
    @account = TwitterUser.find(params[:twitter_user_id])
    @mentions = @account.mentions          

    render :update do |page|
      page.visual_effect :highlight, "mentions", :durations => 0.4
      page.delay(0.4) do
        page.replace "mentions", :partial => "mentions", :locals => { :statuses => @mentions, 
          :account => @account,
          :list_id => 'mentions'}
        end   
    end
    return
  end

end