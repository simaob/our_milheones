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

  validates :value, presence: true, numericality: true

  after_commit :update_user_balance, on: [:create]

  private

  def update_user_balance
    u = User.find(user_id)
    u.balance = u.balance + value
    u.save!
  end
end
