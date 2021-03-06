require File.dirname(__FILE__) + '/../spec_helper'
  
# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.


describe UsersController do
  include AuthenticatedTestHelper
  fixtures :users

  it 'properly loads fixtures with Hash for attribute "profile"' do
    user = User.find(1)
    user.profile.class.should.kind_of?(Hash)
  end

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  
  it 'signs up user in pending state' do
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  
  it 'requires login on signup' do
    create_user(:login => nil)
    assigns[:user].errors.on(:login).should be_nil
    response.should be_redirect
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  it 'activates user' do
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :id => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:message].should match(/Please sign in to continue/)
    flash[:error ].should     be_nil
    User.find_by_email('aaron@example.com').state.should == "active"
    User.authenticate('aaron@example.com', 'monkey').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  def create_user(options = {})
    post :create, :user => { :firstname => 'quire', :lastname => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69', :terms_of_use => "1" }.merge(options)
  end
end

describe UsersController, 'when editing your priorities (user_issues)' do
  fixtures :users
  fixtures :issues
  fixtures :user_issues
  
  describe "on GET 'edit_issue_weights' with valid id, " do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      get :edit_issue_weights, :id => 1
    end
    
    it 'should return success' do
      response.should be_success
    end
    
    it 'should assign to @user' do
      assigns(:user).should_not == nil
    end
    
    it 'should get the proper user' do
      assigns(:user).should == User.find(1)
    end
    
    it 'should render edit_issue_weights.html.erb' do
      response.should render_template('edit_issue_weights')
    end
  end
  
  describe 'on PUT to update_issue_weights with valid data' do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      put :update_issue_weights, :id => 1, :user => {:issue_weights => {1 => 11, 2 => 22, 3 => 33}}
    end
    
    it "should return a redirect" do
      response.should be_redirect
    end
    
    it 'should assign to @user' do
      assigns(:user).should_not be_nil
    end
    
    it 'should update the user_issues table' do
      user = User.find(1)
      user.issue_weights.should == {1 => 11, 2 => 22, 3 => 33}
    end
    
    it 'should NOT set an error message' do
      flash[:error].should be_nil
    end
    
  end
  
  describe 'on PUT to update_issue_weights with invalid data (negative weights)' do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      put :update_issue_weights, :id => 1, :user => {:issue_weights => {1 => 11, 2 => 22, 3 => -33}}
    end
    
    it "should return success" do
      response.should be_success
    end
    
    it "should not return a redirect" do
      response.should_not be_redirect
    end
    
    it "should render edit_issue_weights.html.erb" do
      response.should render_template('edit_issue_weights')
    end
    
    it 'should assign the appropriate user to @user' do 
      assigns(:user).should == User.find(1)
    end
      
    it 'should NOT update the user_issues table' do
      user = User.find(1)
      user.issue_weights.should == {1 => 50, 2 => 50, 3 => 50}
    end
    
    it 'should set an error message' do
      flash[:error].should_not be_nil
    end
    
  end
  
end

describe UsersController, "when editing your profile" do
  describe "on GET 'edit' with valid id," do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      # template.stub!(:current_user).and_return(User.find(1))
      get :edit, :id => 1
    end
    
    it "should return success" do
      response.should be_success
    end
    
    it "should assign to @user" do
      assigns(:user).should_not == nil
    end
    
    it "should get the proper user" do
      assigns(:user).firstname.should == 'Quentin'
    end
    
    it "should render edit.html.erb " do
      response.should render_template('edit')
    end
  end
  
  describe "on PUT 'update' with valid data," do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      put :update, :id => 1, :user => {:firstname => 'NewFirstname', :lastname => 'NewLastname', :profile => {:location => 'newLocation', :website => 'www.NewWebsite.com'}}
    end
    
    it "should return a redirect" do
      response.should be_redirect
    end
    
    it "should update the user" do
      user = User.find(1)
      user.firstname.should == 'NewFirstname'
    end
    
    it "should redirect to show" do
      response.should redirect_to(user_path(assigns(:user)))
    end
    
    it "should assign to user" do 
      assigns(:user).class.should == User
    end
    
    it "should set a flash[:notice] message" do
      flash[:error].should be_nil
      flash[:notice].should_not be_nil
    end
    
  end
  
  describe "on PUT 'update' with invalid data (firstname is invalid with 101 characters)," do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      put :update, :id => 2, :user => {:firstname => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", :lastname => 'NewLast', :profile => {:location => 'newLoc', :website => 'www.newWeb.com'}}
    end
    
    it "should return success" do
      response.should be_success
    end
    
    it "should assign to @user" do
      assigns(:user).class.should == User
    end
    
    it "should not update the user" do
      user = User.find(2)
      user.lastname.should == 'Vader'
    end
    
    it "should render edit" do
      response.should render_template('edit')
    end
    
    it "should assign errors" do
      assigns(:user).errors.should_not == nil
    end
    
  
  end
  
  # not sure how to express this - what is normal failure response? - Luke
  it "on GET 'edit' with invalid id, it should fail - see comments" 
  
  # not sure how to express this either - Luke
  it "on GET 'edit' with no id, it should fail - see comments" 
  
end



describe UsersController, ": when editing a user and you're not logged in," do
  
  fixtures :users
  
  describe "on GET 'edit' with valid id," do
    before do
      get :edit, :id => 1
    end
    
    it "should return success" do
      response.should be_redirect
    end
    
    it "should assign to @user" do
      assigns(:user).should == nil
    end
    
    it "should get the proper user" do
      assigns(:user).should be_nil
    end
    
    it "should not render edit.html.erb " do
      response.should_not render_template('edit')
    end
  end
  
  describe "on PUT 'update' with valid data," do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))
      put :update, :id => 1, :user => {:firstname => 'NewFirstname', :lastname => 'NewLastname', :profile => {:location => 'newLocation', :website => 'www.NewWebsite.com'}}
    end
    
    it "should return a redirect" do
      response.should be_redirect
    end
    
    it "should update the user" do
      user = User.find(1)
      user.firstname.should == 'NewFirstname'
    end
    
    it "should redirect to show" do
      response.should redirect_to(user_path(1))
    end
    
    it "should assign to user" do 
      assigns(:user).class.should == User
    end
    
    it "should not set a flash[:notice] message" do
      flash[:notice].should == "Your user profile has been updated!"
    end
    
  end
  
  describe "on PUT 'update' with invalid data (firstname is invalid with 101 characters)," do
    before do
      controller.stub!(:login_required).and_return(true)
      controller.stub!(:current_user).and_return(User.find(1))      
      put :update, :id => 2, :user => {:firstname => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", :lastname => 'NewLast', :profile => {:location => 'newLoc', :website => 'www.newWeb.com'}}
    end
    
    it "should return success" do
      response.should be_success
    end
    
    it "should assign to @user" do
      assigns(:user).class.should == User
    end
    
    it "should not update the user" do
      user = User.find(2)
      user.lastname.should == 'Vader'
    end
    
  end
  
  # not sure how to express this - what is normal failure response? - Luke
  it "on GET 'edit' with invalid id, it should fail - see comments" 
  
  # not sure how to express this either - Luke
  it "on GET 'edit' with no id, it should fail - see comments" 
  
end

describe UsersController do
  describe "route generation" do
    it "should route users's 'index' action correctly" do
      route_for(:controller => 'users', :action => 'index').should == "/users"
    end
    
    it "should route users's 'new' action correctly" do
      route_for(:controller => 'users', :action => 'new').should == "/signup"
    end
    
    it "should route {:controller => 'users', :action => 'create'} correctly" do
      route_for(:controller => 'users', :action => 'create').should == "/register"
    end
    
    it "should route users's 'show' action correctly" do
      route_for(:controller => 'users', :action => 'show', :id => '1').should == "/users/1"
    end
    
    it "should route users's 'edit' action correctly" do
      route_for(:controller => 'users', :action => 'edit', :id => '1').should == "/users/1/edit"
    end
    
    # it "should route users's 'update' action correctly" do
    #   route_for(:controller => 'users', :action => 'update', :id => '1').should == "/users/1"
    # end
    # 
    # it "should route users's 'destroy' action correctly" do
    #   route_for(:controller => 'users', :action => 'destroy', :id => '1').should == "/users/1"
    # end
  end
  
  describe "route recognition" do
    it "should generate params for users's index action from GET /users" do
      params_from(:get, '/users').should == {:controller => 'users', :action => 'index'}
      params_from(:get, '/users.xml').should == {:controller => 'users', :action => 'index', :format => 'xml'}
      params_from(:get, '/users.json').should == {:controller => 'users', :action => 'index', :format => 'json'}
    end
    
    it "should generate params for users's new action from GET /users" do
      params_from(:get, '/users/new').should == {:controller => 'users', :action => 'new'}
      params_from(:get, '/users/new.xml').should == {:controller => 'users', :action => 'new', :format => 'xml'}
      params_from(:get, '/users/new.json').should == {:controller => 'users', :action => 'new', :format => 'json'}
    end
    
    it "should generate params for users's create action from POST /users" do
      params_from(:post, '/users').should == {:controller => 'users', :action => 'create'}
      params_from(:post, '/users.xml').should == {:controller => 'users', :action => 'create', :format => 'xml'}
      params_from(:post, '/users.json').should == {:controller => 'users', :action => 'create', :format => 'json'}
    end
    
    it "should generate params for users's show action from GET /users/1" do
      params_from(:get , '/users/1').should == {:controller => 'users', :action => 'show', :id => '1'}
      params_from(:get , '/users/1.xml').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'xml'}
      params_from(:get , '/users/1.json').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's edit action from GET /users/1/edit" do
      params_from(:get , '/users/1/edit').should == {:controller => 'users', :action => 'edit', :id => '1'}
    end
    
    it "should generate params {:controller => 'users', :action => update', :id => '1'} from PUT /users/1" do
      params_from(:put , '/users/1').should == {:controller => 'users', :action => 'update', :id => '1'}
      params_from(:put , '/users/1.xml').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'xml'}
      params_from(:put , '/users/1.json').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's destroy action from DELETE /users/1" do
      params_from(:delete, '/users/1').should == {:controller => 'users', :action => 'destroy', :id => '1'}
      params_from(:delete, '/users/1.xml').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml'}
      params_from(:delete, '/users/1.json').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'json'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route users_path() to /users" do
      users_path().should == "/users"
      users_path(:format => 'xml').should == "/users.xml"
      users_path(:format => 'json').should == "/users.json"
    end
    
    it "should route new_user_path() to /users/new" do
      new_user_path().should == "/users/new"
      new_user_path(:format => 'xml').should == "/users/new.xml"
      new_user_path(:format => 'json').should == "/users/new.json"
    end
    
    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
      user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end
    
    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
  
end
