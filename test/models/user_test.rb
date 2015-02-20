# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  name                   :string
#  created_at             :datetime
#  updated_at             :datetime
#  balance                :float            default("0.0")
#  is_admin               :boolean          default("false")
#  default_bet            :json
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "recent bets should be empty if no bets" do
    Bet.delete_all
    assert_equal [], @user.recent_bets(5)
  end

  test "recent bets return all of users bets" do
    bet = {numbers: "1,2,3,4,5", stars: "1,2"}
    5.times do |i|
      week = Week.create(number: i, friday: i.weeks.ago)
      Bet.create(user_id: @user.id, week_id: week.id, bet: bet)
    end
    assert_equal 5, @user.recent_bets(5).size
  end

  test "recent bets return all but one users bets" do
    bet = {numbers: "1,2,3,4,5", stars: "1,2"}
    last_bet = nil
    6.times do |i|
      week = Week.create(number: i, friday: i.weeks.ago)
      last_bet = Bet.create(user_id: @user.id, week_id: week.id, bet: bet)
    end
    assert_equal 1, (@user.bets.size - @user.recent_bets(5).size)
    assert_equal last_bet, (@user.bets - @user.recent_bets(5)).first
  end
end
