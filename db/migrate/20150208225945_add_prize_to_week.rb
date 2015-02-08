class AddPrizeToWeek < ActiveRecord::Migration
  def change
    add_column :weeks, :prize, :float, default: 0.0
  end
end
