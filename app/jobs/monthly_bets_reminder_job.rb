# Reminds the admins to place next month's bets (the syndicate bets once a month).
# Scheduled two days before the end of each month in config/recurring.yml; it
# replaced the weekly Friday "do the bets" reminder.
class MonthlyBetsReminderJob < ApplicationJob
  queue_as :default

  def perform
    BetMailer.monthly_bets_reminder(Date.current.next_month.beginning_of_month).deliver_now
  end
end
