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
      post :create, params: { user: { email: "simao@tatara.pt", name: @user.name } }
    end

    assert_redirected_to users_path()
  end

  test "should show user" do
    get :show, params: { id: @user }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @user }
    assert_response :success
  end

  test "should not get edit" do
    sign_out @admin
    sign_in @user
    get :edit, params: { id: @admin }
    assert_redirected_to root_path
  end

  test "should update user" do
    patch :update, params: { id: @user, user: { email: "simao@cenas.com" } }
    assert_redirected_to user_path(assigns(:user))
    assert_equal "simao@cenas.com", @user.reload.email
  end

  test "non-admin can update themselves" do
    sign_out @admin
    sign_in @user
    patch :update, params: { id: @user, user: { name: "New Name" } }
    assert_redirected_to user_path(@user)
    assert_equal "New Name", @user.reload.name
  end

  test "non-admin cannot update another user" do
    sign_out @admin
    sign_in @user
    patch :update, params: { id: @admin, user: { email: "hijacked@example.com", password: "hijacked123", password_confirmation: "hijacked123" } }
    assert_redirected_to root_path
    @admin.reload
    assert_equal "simao@fe.up.pt", @admin.email
    assert_not @admin.valid_password?("hijacked123")
  end

end
