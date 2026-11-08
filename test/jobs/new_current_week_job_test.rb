require 'test_helper'

class NewCurrentWeekJobTest < ActiveJob::TestCase
  test "charges every user the bet cost for the current week" do
    travel_to Date.new(2026, 11, 9) do # a Monday; that week's draw is Friday 13/11/2026
      assert_difference -> { Transaction.count }, User.count do
        NewCurrentWeekJob.perform_now
      end

      week = Week.find_by!(friday: Date.new(2026, 11, 13))
      charges = Transaction.where(date: Date.today)
      assert_equal User.count, charges.count
      assert charges.all? { |t| t.value == Bet::BET_COST && t.kind == TransactionKind::BET }
      assert_equal "Bet for week number #{week.number} (13/11/2026)", charges.first.details
    end
  end
end
