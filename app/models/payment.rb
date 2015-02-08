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

class Payment < ActiveRecord::Base
  belongs_to :user
end
