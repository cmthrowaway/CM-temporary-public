require File.expand_path(File.dirname(__FILE__)+ '/../../spec_helper')

describe "/users/show.html.erb" do
  
  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :id => 1,
      :firstname => "value for firstname",
      :lastname => "value for lastname",
      :email => "value for email",
      :location => "value for location",
      :website => "value for website"
    )
    @controller.instance_variable_set(:@url, (ActionController::UrlRewriter.new @request, {}))
    
    template.stub!(:edit_object_url).and_return(edit_user_path(@user))
    template.stub!(:collection_url).and_return(users_path)

  end

  it "should render the user's attributes" do
    render "/users/show.html.erb"
    response.should have_text(/value\ for\ firstname/)
    response.should have_text(/value\ for\ lastname/)
    response.should have_text(/value\ for\ email/)
    response.should have_text(/value\ for\ location/)
    response.should have_text(/value\ for\ website/)
  end
  
  it "should have link to edit your profile when logged in and looking at your profile" do
    template.stub!(:current_user).and_return(@user)
    render "/users/show.html.erb"
    response.should have_tag("a[href=?]", edit_user_path(@user))
  end


  it "should not have link to edit" do
    render "/users/show.html.erb"
    response.should_not have_tag("a[href=?]", edit_user_path(@user))
  end
  
end