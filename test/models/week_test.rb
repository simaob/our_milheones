# == Schema Information
#
# Table name: weeks
#
#  id            :integer          not null, primary key
#  number        :integer
#  friday        :date
#  solution      :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  prize         :float            default("0.0")
#  prize_details :text
#  weeks_bet     :string
#

require 'test_helper'

class WeekTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @week = weeks(:one)
  end

  test "bets missing should return 0 if no users" do
    User.delete_all
    assert_equal 0, @week.bets_missing
  end

  test "bets missing should return number users if no bets" do
    Bet.delete_all
    assert_equal User.count, @week.bets_missing
  end

  test "bets missing should return number users - bets for week" do
    bet = Bet.create(week_id: @week.id, bet: {numbers: "1, 2, 3, 4, 5",
      stars: "1, 2" }, user_id: users(:one).id)
    @week.reload
    assert_equal User.count-1, @week.bets_missing
  end

  test "current creates this week's row once and reuses it" do
    travel_to Date.new(2026, 11, 9) do
      week = nil
      assert_difference -> { Week.count }, 1 do
        week = Week.current
      end
      assert_equal Date.new(2026, 11, 13), week.friday
      assert_no_difference -> { Week.count } do
        assert_equal week, Week.current
      end
    end
  end

  test "current loads the week another process created between lookup and insert" do
    travel_to Date.new(2026, 11, 9) do
      friday = Date.new(2026, 11, 13)
      winner = Week.create!(number: friday.strftime("%U").to_i, friday: friday)

      # Make the first lookup miss, as if it ran just before the winner's insert.
      lookups = 0
      Week.define_singleton_method(:find_by) do |*args|
        lookups += 1
        lookups == 1 ? nil : super(*args)
      end

      begin
        assert_no_difference -> { Week.count } do
          assert_equal winner, Week.current
        end
      ensure
        Week.singleton_class.remove_method(:find_by)
      end
    end
  end

  test "members picked their own bets until June 2017" do
    assert Week.new(friday: Date.new(2017, 6, 9)).member_bets?
    assert_not Week.new(friday: Date.new(2017, 6, 16)).member_bets?
  end

  test "a bet was made when its slip was uploaded" do
    assert_not @week.bet_made?
    @week.update!(weeks_bet: File.open(file_fixture("proof.png")))
    assert @week.reload.bet_made?
  end

  test "the database rejects a duplicate week" do
    assert_raises ActiveRecord::RecordNotUnique do
      Week.new(number: @week.number, friday: @week.friday).save!(validate: false)
    end
  end
end
