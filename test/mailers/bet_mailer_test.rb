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

  test "monthly_bets_reminder goes to the admins" do
    assert_renders BetMailer.monthly_bets_reminder(Date.new(2026, 12, 1)), to: [ users(:one).email ],
      subject: "[Euromilhões] Bets for December 2026"
  end

  private
    def assert_renders(email, to:, subject: "Re: [Euromilhões] #{@week.friday.to_fs}")
      assert_equal to.sort, email.to.sort
      assert_equal [ "no-reply@simaobelchior.net" ], email.from
      assert_equal subject, email.subject
      assert_equal [ "text/html", "text/plain" ], email.parts.map(&:mime_type).sort
      email.parts.each { |part| assert_predicate part.body.to_s.strip, :present? }
    end
end
