# == Schema Information
#
# Table name: bets
#
#  id         :integer          not null, primary key
#  bet        :json
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Bet < ActiveRecord::Base
end
