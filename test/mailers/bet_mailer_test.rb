require "test_helper"

# Renders every email the app sends, both the HTML and the text part.
class BetMailerTest < ActionMailer::TestCase
  setup do
    @week = weeks(:one)
  end

  test "prize_won goes to everyone" do
    assert_renders BetMailer.prize_won(@week), to: User.pluck(:email)
  end

  test "bets_made goes to everyone" do
    assert_renders BetMailer.bets_made(@week), to: User.pluck(:email)
  end

  test "do_the_bets goes to the admins" do
    assert_renders BetMailer.do_the_bets(@week), to: [ users(:one).email ]
  end

  private
    def assert_renders(email, to:)
      assert_equal to.sort, email.to.sort
      assert_equal [ "no-reply@simaobelchior.net" ], email.from
      assert_equal "Re: [Euromilhões] #{@week.friday.to_fs}", email.subject
      assert_equal [ "text/html", "text/plain" ], email.parts.map(&:mime_type).sort
      email.parts.each { |part| assert_predicate part.body.to_s.strip, :present? }
    end
end
