require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    sign_in @user
    @transaction = transactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transaction" do
    assert_difference('Transaction.count') do
      post :create, transaction: { date: @transaction.date,
        details: @transaction.details, user_id: @transaction.user_id,
        value: @transaction.value, kind: @transaction.kind }
    end

    assert_redirected_to transactions_path
  end
end
