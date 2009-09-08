require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe ReviewsController do
  include AuthenticatedTestHelper
  
  fixtures :reviews
  before(:each) do
    login_as(mock_user)
  end
  
  def mock_review(stubs={})
    @mock_review ||= mock_model(Review, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all reviews as @reviews" do
      Review.should_receive(:find).with(:all).and_return([mock_review])
      get :index
      assigns[:reviews].should == [mock_review]
    end

  end

  describe "responding to GET show" do

    it "should expose the requested review as @review" do
      Review.should_receive(:find).with("37").and_return(mock_review)
      get :show, :id => "37"
      assigns[:review].should equal(mock_review)
    end
        
  end

  describe "responding to GET new" do
  
    it "should expose a new review as @review" do
      Review.should_receive(:new).and_return(mock_review)
      get :new      
      assigns[:review].should equal(mock_review)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested review as @review" do
      Review.should_receive(:find).with("37").and_return(mock_review)
      get :edit, :id => "37"
      assigns[:review].should equal(mock_review)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created review as @review" do        
        post :create, :review_presenter => {
          :body => "body of review",
          :rating => 5
        }, :company_id => 2, :issues => {1 => 1} 
        assigns[:review].should be_valid
        response.should redirect_to(company_url(2))
      end

      it "should redirect to the created review" do
        post :create, :review_presenter => {
          :body => "body of review",
          :rating => 5
        }, :company_picker_id => 2, :issues => {1 => "other"} 
        response.should redirect_to(company_url(2))
      end
      
    end
    
    describe "with invalid params" do

      it "should render the new action with the errors" do
        post :create, :review_presenter => {}, :company_id => 1
        response.should render_template('new')
        assigns[:review].errors.empty?.should_not be_true
      end
            
    end
    
  end

  describe "responding to PUT udpate" do
    
    before do
      login_as(mock_user)
    end
    
    describe "with valid params" do      
      it "should update the requested review" do
        Review.should_receive(:find).with("1").and_return(mock_review(:update_attributes => true))
        mock_review.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "1", "review" => {:these => 'params'}
      end

      it "should expose the requested review as @review" do
        Review.stub!(:find).and_return(mock_review(:update_attributes => true))
        put :update, :id => "1"
        assigns(:review).should equal(mock_review)
      end

      it "should redirect to the review" do
        Review.stub!(:find).and_return(mock_review(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(review_url(mock_review))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested review" do
        Review.should_receive(:find).with("2").and_return(mock_review(:update_attributes => true))
        mock_review.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "2", :review => {:these => 'params'}
      end

      it "should expose the review as @review" do
        Review.stub!(:find).and_return(mock_review(:update_attributes => false))
        put :update, :id => "1"
        assigns(:review).should equal(mock_review)
      end

      it "should re-render the 'edit' template" do
        Review.stub!(:find).and_return(mock_review(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do
    before(:each) do
      @review = mock_model(Review, :destroy => true)
      Review.stub!(:find).and_return(@review)
    end
    
    def do_delete
      delete :destroy, :id => "1"
    end
    
    it "should destroy the requested review" do
      Review.should_receive(:find).with("1").and_return(@review)
      do_delete
    end
  
    it "should redirect to the reviews list" do
      Review.stub!(:find).and_return(@review)
      do_delete
      response.should redirect_to(reviews_url)
    end

  end

end
