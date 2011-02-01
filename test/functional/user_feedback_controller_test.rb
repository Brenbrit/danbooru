require 'test_helper'

class UserFeedbackControllerTest < ActionController::TestCase
  context "The user feedback controller" do
    setup do
      @user = Factory.create(:user)
      @critic = Factory.create(:privileged_user)
      CurrentUser.user = @critic
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @critic.id}
        assert_response :success
      end
    end
    
    context "edit action" do
      setup do
        @user_feedback = Factory.create(:user_feedback)
      end
      
      should "render" do
        get :edit, {:id => @user_feedback.id}, {:user_id => @critic.id}
        assert_response :success
      end
    end
    
    context "index action" do
      setup do
        @user_feedback = Factory.create(:user_feedback)
      end
      
      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end
      
      context "with search parameters" do
        should "render" do
          get :index, {:search => {:user_id_equals => @user.id}}, {:user_id => @critic.id}
          assert_response :success
        end
      end
    end
    
    context "create action" do
      should "create a new feedback" do
        assert_difference("UserFeedback.count", 1) do
          post :create, {:user_feedback => {:is_positive => false, :user_name => @user.name, :body => "xxx"}}, {:user_id => @critic.id}
          assert_not_nil(assigns(:user_feedback))
          assert_equal([], assigns(:user_feedback).errors.full_messages)
        end
      end
    end
    
    context "destroy action" do
      setup do
        @user_feedback = Factory.create(:user_feedback)
      end
      
      should "delete a feedback" do
        assert_difference "UserFeedback.count", -1 do
          post :destroy, {:id => @user_feedback.id}, {:user_id => @critic.id}
        end
      end
    end
  end
end
