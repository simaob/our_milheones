# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  name                   :string
#  created_at             :datetime
#  updated_at             :datetime
#  balance                :float            default("0.0")
#  is_admin               :boolean          default("false")
#  default_bet            :json
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  has_many :bets
  has_many :transactions

  before_validation do |model|
    if model.default_bet && !model.default_bet['numbers'].is_a?(Array)
      model.default_bet['numbers'] = model.default_bet['numbers'].split(",")
      model.default_bet['numbers'].map!(&:to_i).sort!
      model.default_bet['stars'] = model.default_bet['stars'].split(",")
      model.default_bet['stars'].map!(&:to_i).sort!
    end
  end


  def recent_bets n
    bets.joins(:week).order('weeks.friday DESC').limit(n)
  end

  def recent_transactions n
    transactions.order('created_at DESC').limit(n)
  end

  def stats
    stats = {}
    stats[:total_bets] = bets.size
    stats[:total_transactions] = transactions.size
    stats[:balance] = balance
    stats[:member_since] = created_at.strftime("%d/%m/%Y")
    stats
  end
end
