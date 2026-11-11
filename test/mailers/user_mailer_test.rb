require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome_email sends the new user their password" do
    user = users(:two)
    email = UserMailer.welcome_email(user, "s3cret-pass")

    assert_equal [ user.email ], email.to
    assert_equal [ "no-reply@simaobelchior.net" ], email.from
    assert_equal "[Euromilhões] Conta criada", email.subject
    assert_equal [ "text/html", "text/plain" ], email.parts.map(&:mime_type).sort
    email.parts.each { |part| assert_includes part.body.to_s, "s3cret-pass" }
  end
end
