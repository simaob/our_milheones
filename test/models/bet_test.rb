# == Schema Information
#
# Table name: bets
#
#  id         :integer          not null, primary key
#  bet        :json
#  user_id    :integer
#  week_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class BetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "numbers should return empty if no bet" do
    bet = Bet.new
    assert_equal "", bet.numbers
  end

  test "numbers should return bet numbers" do
    bet = Bet.new(bet: { numbers: [1, 2, 3] })
    assert_equal [1, 2, 3], bet.numbers
  end

  test "stars should return empty if no bet" do
    bet = Bet.new
    assert_equal "", bet.stars
  end

  test "stars should return bet stars" do
    bet = Bet.new(bet: { stars: [1, 2, 3] })
    assert_equal [1, 2, 3], bet.stars
  end
end
