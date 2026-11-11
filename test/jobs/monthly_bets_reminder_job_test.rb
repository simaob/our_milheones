require "test_helper"
require "fugit" # the schedule parser Solid Queue uses

class MonthlyBetsReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "asks the admins to place next month's bets" do
    travel_to Time.zone.local(2026, 11, 28, 9) do
      assert_emails 1 do
        MonthlyBetsReminderJob.perform_now
      end
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ users(:one).email ], mail.to
    assert_equal "[Euromilhões] Bets for December 2026", mail.subject
    assert_includes mail.text_part.body.to_s, "time to place the bets for December 2026"
  end

  test "in December it is about January of the next year" do
    travel_to Time.zone.local(2026, 12, 29, 9) do
      MonthlyBetsReminderJob.perform_now
    end
    assert_equal "[Euromilhões] Bets for January 2027", ActionMailer::Base.deliveries.last.subject
  end

  test "sends nothing when there are no admins" do
    User.update_all(is_admin: false)
    assert_no_emails do
      MonthlyBetsReminderJob.perform_now
    end
  end

  test "is scheduled at 09:00 Lisbon time, two days before the last day of each month" do
    tasks = YAML.load_file(Rails.root.join("config/recurring.yml")).fetch("production")
    assert_not tasks.key?("do_the_bets"), "the weekly Friday reminder was replaced by this one"

    task = tasks.fetch("monthly_bets_reminder")
    assert_equal "MonthlyBetsReminderJob", task["class"]

    schedule = Fugit.parse(task["schedule"], multi: :fail) # how Solid Queue parses it
    time = Time.zone.local(2026, 11, 11)
    runs = 6.times.map { time = schedule.next_time(time).to_t.in_time_zone; time.strftime("%Y-%m-%d %H:%M") }
    assert_equal [ "2026-11-28 09:00", "2026-12-29 09:00", "2027-01-29 09:00",
                   "2027-02-26 09:00", "2027-03-29 09:00", "2027-04-28 09:00" ], runs
  end
end
