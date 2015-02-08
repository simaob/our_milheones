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

  def numbers
    return "" unless bet
    bet["numbers"]
  end

  def stars
    return "" unless bet
    bet["stars"]
  end
end
