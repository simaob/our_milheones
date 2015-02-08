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
  belongs_to :user
  belongs_to :week

  validates :week_id, presence: true, uniqueness: [:user_id]
  validates :user_id, presence: true

  before_validation do |model|
    if model.bet
      model.bet['numbers'].reject!(&:blank?)
      model.bet['numbers'].map!(&:to_i).sort!
      model.bet['stars'].reject!(&:blank?)
      model.bet['stars'].map!(&:to_i).sort!
    end
  end

  def print_numbers solution=nil
    if solution
      numbers.map do |n|
        if solution.include?(n)
          "<strong>#{n}</strong>"
        else
          n
        end
      end
    else
      numbers
    end.join(", ")
  end

  def numbers
    return "" unless bet
    bet["numbers"]
  end

  def print_stars solution=nil
    if solution
      stars.map do |s|
        if solution.include?(s)
          "<strong>#{s}</strong>"
        else
          s
        end
      end
    else
      stars
    end.join(", ")
  end

  def stars
    return "" unless bet
    bet["stars"]
  end
end
