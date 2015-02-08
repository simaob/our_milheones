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
end
