require 'test_helper'

class WeeksControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    sign_in @user
    @week = weeks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weeks)
  end

  test "should show week" do
    get :show, id: @week
    assert_response :success
  end
end
