require 'test_helper'

class BetsControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    sign_in @user
    @week = weeks(:one)
    @bet = bets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bets)
  end

  test "should show bet" do
    get :show, params: { id: @bet }
    assert_response :success
  end

  test "should destroy bet" do
    assert_difference('Bet.count', -1) do
      delete :destroy, params: { id: @bet }
    end

    assert_redirected_to bets_path
  end
end
