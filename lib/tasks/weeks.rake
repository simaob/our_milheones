namespace :weeks do

  desc "Generate next week"
  task create_week: :environment do
    friday = Date.today.end_of_week
    week_number = friday.strftime("%U").to_i
    Week.find_or_create_by(number: week_number, friday: friday)
  end

  desc "Request bets for current week"
  task request_bets: :create_week do
    friday = Date.today.end_of_week
    week_number = friday.strftime("%U").to_i
    week = Week.find_or_create_by(number: week_number, friday: friday)
    week.fill_default_bets
    BetMailer.make_your_bets(week).deliver_now
  end

  desc "Remind users to do their bets if they haven't already"
  task remind_users: :environment do
    friday = Date.today.end_of_week
    week_number = friday.strftime("%U").to_i
    week = Week.find_by(number: week_number, friday: friday)
    BetMailer.bet_reminder(week).deliver_now
  end
end
