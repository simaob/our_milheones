# == Schema Information
#
# Table name: transactions
#
#  id         :integer          not null, primary key
#  value      :float
#  user_id    :integer
#  details    :text
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kind       :integer          not null
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
