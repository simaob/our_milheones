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

  test "should get edit" do
    get :edit, id: @week
    assert_response :success
  end

  test "should update week's solution" do
    solution = { numbers: @week.solution['numbers'].join(","),
                 stars: @week.solution['stars'].join(",") }
    patch :update, id: @week, week: { solution: solution }
    assert_redirected_to week_path(assigns(:week))
  end

  test "should update week's prize" do
    patch :update, id: @week, week: { prize: '20.0' }
    assert_redirected_to week_path(assigns(:week))
    assert_equal 20.0, assigns(:week).prize
  end
end
