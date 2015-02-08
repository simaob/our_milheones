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

  before_validation do |model|
    if model.solution
      model.solution['numbers'].reject!(&:blank?)
      model.solution['numbers'].map!(&:to_i).sort!
      model.solution['stars'].reject!(&:blank?)
      model.solution['stars'].map!(&:to_i).sort!
    end
  end

  def bets_missing
    User.count - bets.size
  end

  def bet_from user
    bets.find_by(user_id: user.id)
  end

  def print_solution
    return "" unless solution
    "#{solution["numbers"].join(", ")} + #{solution["stars"].join(", ")}"
  end
end
