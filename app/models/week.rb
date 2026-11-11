# == Schema Information
#
# Table name: weeks
#
#  id            :integer          not null, primary key
#  number        :integer
#  friday        :date
#  solution      :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  prize         :float            default("0.0")
#  prize_details :text
#  weeks_bet     :string
#

class Week < ApplicationRecord
  # Until this date each member picked their own numbers (the Bet rows, shown as
  # "Your bet"). Since then the syndicate places the bets itself, weekly at
  # first and once a month these days, and uploads the slip to the week it was
  # made on ("Bet made").
  MEMBER_BETS_UNTIL = Date.new(2017, 6, 11)

  attr_accessor :update_type
  mount_uploader :weeks_bet, WeeksBetUploader

  has_many :bets

  validates :number, uniqueness: { scope: :friday }

  # The week whose draw is this coming Friday (weeks start on Saturday,
  # see config.beginning_of_week).
  #
  # A web request and the Monday job can both miss the week and try to create
  # it. The unique index on (number, friday) lets only one insert win; the
  # loser fails validation or hits the index, and loads the winner's row.
  def self.current
    friday = Date.current.end_of_week
    attributes = { number: friday.strftime("%U").to_i, friday: friday }
    find_by(attributes) || transaction(requires_new: true) { create!(attributes) }
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    find_by!(attributes)
  end

  before_validation do |model|
    if model.solution && model.changes.include?(:solution)
      model.solution['numbers'] = model.solution['numbers'].split(",")
      model.solution['numbers'].map!(&:to_i).sort!
      model.solution['stars'] = model.solution['stars'].split(",")
      model.solution['stars'].map!(&:to_i).sort!
    end
  end

  # Whether this week's bets were each member's own picks.
  def member_bets?
    friday < MEMBER_BETS_UNTIL
  end

  # Whether the bet slip was uploaded. Reads the stored filename, so it doesn't
  # check the file on disk.
  def bet_made?
    weeks_bet_identifier.present?
  end

  def bets_missing
    User.count - bets.size
  end

  def users_missing_bets
    User.all - bets.map(&:user)
  end

  def bet_from user
    bets.find_by(user_id: user.id)
  end

  def sorted_bets
    bets.joins(:user).order('users.name ASC')
  end

  def register_prize
    total = User.count
    divided = prize/total
    User.all.each do |u|
      Transaction.create(
        user_id: u.id,
        value: divided,
        kind: TransactionKind::PRIZE,
        details: "Prize (#{prize}/#{total} users = #{divided}) for"+
          " week number #{number} (#{friday.to_fs})",
        date: Date.current
      )
    end
    BetMailer.prize_won(self).deliver_later
  end

  def fill_default_bets
    User.all.each do |u|
      if u.default_bet.present?
        bet = Bet.find_or_initialize_by(user_id: u.id, week_id: self.id)
        bet.bet = u.default_bet
        bet.save
      end
    end
  end
end
