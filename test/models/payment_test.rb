# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  value      :float
#  user_id    :integer
#  details    :text
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
