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

class Bet < ActiveRecord::Base

  BET_COST = -2.0

  belongs_to :user
  belongs_to :week

  validates :week_id, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  before_validation do |model|
    if model.bet
      model.bet['numbers'] = model.bet['numbers'].split(",")
      model.bet['numbers'].map!(&:to_i).sort!
      model.bet['stars'] = model.bet['stars'].split(",")
      model.bet['stars'].map!(&:to_i).sort!
    end
  end

  validate :bet_is_right

  after_commit :add_transaction, on: [:create]

  def numbers
    return [] unless bet
    bet["numbers"]
  end

  def stars
    return [] unless bet
    bet["stars"]
  end

  private

  def add_transaction
    Transaction.create(
      user_id: user_id,
      value: BET_COST,
      kind: TransactionKind::BET,
      details: "Bet for week number #{week.number} (#{week.friday})",
      date: Date.today
    )
  end

  def bet_is_right
    unless bet && bet['numbers'].size == 5 && bet['stars'].size == 2
      errors.add(:bet, "not valid. Please select 5 numbers and 2 stars")
    end
  end
end
