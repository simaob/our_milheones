namespace :weeks do

  desc "Add new current week"
  task new_current_week: :environment do
    NewCurrentWeekJob.perform_now
  end

  desc "Remind users to do their bets if they haven't already"
  task remind_users: :environment do
    BetMailer.bet_reminder(Week.current).deliver_now
  end

  desc "Check all bets are done, and request admin to do them"
  task do_the_bets: :environment do
    DoTheBetsJob.perform_now
  end
end
