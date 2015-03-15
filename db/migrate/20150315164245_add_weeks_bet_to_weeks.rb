class AddWeeksBetToWeeks < ActiveRecord::Migration
  def change
    add_column :weeks, :weeks_bet, :string
  end
end
