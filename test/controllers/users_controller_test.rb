require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:one)
    sign_in @admin
    @user = users(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { email: "simao@tatara.pt", name: @user.name }
    end

    assert_redirected_to users_path()
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should not get edit" do
    sign_out @admin
    sign_in @user
    get :edit, id: @admin
    assert_redirected_to root_path
  end

  test "should update user" do
    patch :update, id: @user, user: { email: "simao@cenas.com" }
    assert_redirected_to user_path(assigns(:user))
  end

end
