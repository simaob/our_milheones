# == Schema Information
#
# Table name: weeks
#
#  id         :integer          not null, primary key
#  number     :integer
#  friday     :date
#  solution   :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
    bet = Bet.create(week_id: @week.id, bet: {numbers: [1, 2, 3, 4, 5],
      stars: [1, 2] }, user_id: users(:one).id)
    @week.reload
    assert_equal User.count-1, @week.bets_missing
  end
end
