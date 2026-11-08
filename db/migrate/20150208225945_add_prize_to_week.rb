class AddPrizeToWeek < ActiveRecord::Migration[4.2]
  def change
    add_column :weeks, :prize, :float, default: 0.0
  end
end
