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

class Week < ActiveRecord::Base
  attr_accessor :update_type
  mount_uploader :weeks_bet, WeeksBetUploader

  has_many :bets

  validates :number, uniqueness: { scope: :friday }

  before_validation do |model|
    if model.solution && model.changes.include?(:solution)
      model.solution['numbers'] = model.solution['numbers'].split(",")
      model.solution['numbers'].map!(&:to_i).sort!
      model.solution['stars'] = model.solution['stars'].split(",")
      model.solution['stars'].map!(&:to_i).sort!
    end
  end

  def bets_missing
    User.count - bets.size
  end

  def users_missing_bets
    User.all - bets.map(&:user)
  end

  def bet_from user
    bets.find_by(user_id: user.id)
  end

  def register_prize
    total = User.count
    divided = prize/total
    User.all.each do |u|
      Transaction.create(
        user_id: u.id,
        value: divided,
        kind: TransactionKind::PRIZE,
        details: "Prize (#{prize}/#{total} users = #{divided}) for"+
          " week number #{number} (#{friday})",
        date: Date.today
      )
    end
    BetMailer.prize_won(self).deliver_later
  end

  def fill_default_bets
    User.all.each do |u|
      if u.default_bet.present?
        bet = Bet.find_or_initialize_by(user_id: u.id, week_id: self.id)
        bet.bet = u.default_bet
        bet.save
      end
    end
  end
end
