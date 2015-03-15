namespace :weeks do

  desc "Request bets for current week"
  task request_bets: :environment do
    week = current_week
    week.fill_default_bets
    BetMailer.make_your_bets(week).deliver_now
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

