namespace :weeks do

  desc "Add new current week"
  task new_current_week: :environment do
    week = current_week
    # adds transaction for each user
    User.all.each do |u|
      Transaction.create(
        user_id: u.id,
        value: Bet::BET_COST,
        kind: TransactionKind::BET,
        details: "Bet for week number #{week.number} (#{week.friday})",
        date: Date.today)
    end
  end

  desc "Remind users to do their bets if they haven't already"
  task remind_users: :environment do
    week = current_week
    BetMailer.bet_reminder(week).deliver_now
  end

  desc "Check all bets are done, and request admin to do them"
  task do_the_bets: :environment do
    week = current_week
    BetMailer.do_the_bets(week).deliver_now unless week.weeks_bet.present?
  end
end

def current_week
  friday = Date.today.end_of_week
  week_number = friday.strftime("%U").to_i
  Week.find_or_create_by(number: week_number, friday: friday)
end

