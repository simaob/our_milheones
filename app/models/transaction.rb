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

class Transaction < ActiveRecord::Base
  has_enumeration_for :kind, :with => TransactionKind,
    :create_helpers => true
  belongs_to :user

  validates :value, presence: true, numericality: true
  validates :user_id, presence: true

  after_commit :update_user_balance, on: [:create]

  private

  def update_user_balance
    u = User.find(user_id)
    u.balance = u.balance + value
    u.save!
  end
end
