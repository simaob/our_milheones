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

class Week < ActiveRecord::Base

  has_many :bets

  validates :number, uniqueness: { scope: :friday }

  def bets_missing
    User.count - bets.size
  end

  def bet_from user
    bet = bets.find_by(user_id: user.id)
    return "Bet missing!" unless bet
    "#{bet.print_numbers} + #{bet.print_stars}"
  end
end
