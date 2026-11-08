class AddWeeksBetToWeeks < ActiveRecord::Migration[4.2]
  def change
    add_column :weeks, :weeks_bet, :string
  end
end
