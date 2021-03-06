require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reviews/index.html.erb" do
  
  fixtures :users
  
  before(:each) do
    
    review_1 =  stub_model(Review,
      :body => "value for body",
      :status => "value for status",
      :company_id => 1, 
      :user_id => 1,
      :created_at => Time.now
    )

    review_2 =  stub_model(Review,
      :body => "value for body",
      :status => "value for status",
      :company_id => 1,
      :user_id => 1,
      :created_at => Time.now
    )
    
    assigns[:reviews] = [
      review_1,
      review_2
    ]
    @controller.instance_variable_set(:@url, (ActionController::UrlRewriter.new @request, {}))
    
    template.stub!(:object_url).and_return(review_path(review_1))
    template.stub!(:new_object_url).and_return(new_review_path())
    template.stub!(:edit_object_url).and_return(edit_review_path(review_1))

    
  end

  it "should render list of reviews" do
    render "/reviews/index.html.erb"
    response.should have_tag("div.body", :text => "value for body")
    #response.should have_tag("tr>td", "value for status", 2)
  end
end

