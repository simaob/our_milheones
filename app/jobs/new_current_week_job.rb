# Opens the current week by charging every user the cost of their bet.
# Scheduled every Monday morning in config/recurring.yml (it used to be a
# `whenever` cron entry running `rake weeks:new_current_week`).
class NewCurrentWeekJob < ApplicationJob
  queue_as :default

  def perform
    week = Week.current
    User.all.each do |u|
      Transaction.create(
        user_id: u.id,
        value: Bet::BET_COST,
        kind: TransactionKind::BET,
        details: "Bet for week number #{week.number} (#{week.friday.to_fs})",
        date: Date.today)
    end
  end
end
