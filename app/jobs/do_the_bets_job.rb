# Reminds the admins to place this week's bets, unless the proof of the bet
# has already been uploaded. Scheduled every Friday in config/recurring.yml
# (it used to be a `whenever` cron entry running `rake weeks:do_the_bets`).
class DoTheBetsJob < ApplicationJob
  queue_as :default

  def perform
    week = Week.current
    BetMailer.do_the_bets(week).deliver_now unless week.weeks_bet.present?
  end
end
