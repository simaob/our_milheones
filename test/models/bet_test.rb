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

require 'test_helper'

class BetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
