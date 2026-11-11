require "test_helper"

# The whole "Forgot your password?" flow, through the app's own Devise views.
class PasswordResetTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    ActionMailer::Base.deliveries.clear
  end

  test "the forgot password page renders" do
    get new_user_password_path
    assert_response :success
    assert_select "input[type=email][name='user[email]']"
  end

  test "an unknown email shows the error on the form" do
    post user_password_path, params: { user: { email: "nobody@example.com" } }
    assert_select "#error_explanation li", /Email not found/
    assert_empty ActionMailer::Base.deliveries
  end

  test "requesting a reset emails a link that lets the user set a new password" do
    post user_password_path, params: { user: { email: @user.email } }
    assert_redirected_to new_user_session_path

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ @user.email ], mail.to
    assert_equal [ "no-reply@simaobelchior.net" ], mail.from
    token = mail.body.to_s[/reset_password_token=([^"&]+)/, 1]
    assert token, "the email should contain the reset link"

    get edit_user_password_path(reset_password_token: token)
    assert_response :success

    put user_password_path, params: { user: { reset_password_token: token, password: "new-secret-1", password_confirmation: "does-not-match" } }
    assert_select "#error_explanation li", /Password confirmation doesn't match/

    put user_password_path, params: { user: { reset_password_token: token, password: "new-secret-1", password_confirmation: "new-secret-1" } }
    assert_redirected_to root_path
    assert @user.reload.valid_password?("new-secret-1")
  end
end
