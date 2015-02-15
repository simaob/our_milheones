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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bet" do
    bet = {numbers: @bet.numbers.join(","), stars: @bet.stars.join(",") }
    assert_difference('Bet.count') do
      post :create, bet: { bet: bet, user_id: @bet.user_id,
        week_id: @week.id }
    end

    assert_redirected_to bet_path(assigns(:bet))
  end

  test "should show bet" do
    get :show, id: @bet
    assert_response :success
  end

  test "should update bet" do
    bet = {numbers: @bet.numbers.join(","), stars: @bet.stars.join(",") }
    patch :update, id: @bet, bet: { bet: bet, user_id: @bet.user_id,
      week_id: @week.id }
    assert_redirected_to bet_path(assigns(:bet))
  end

  test "should destroy bet" do
    assert_difference('Bet.count', -1) do
      delete :destroy, id: @bet
    end

    assert_redirected_to bets_path
  end
end
