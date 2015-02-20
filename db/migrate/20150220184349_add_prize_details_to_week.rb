class AddPrizeDetailsToWeek < ActiveRecord::Migration
  def change
    add_column :weeks, :prize_details, :text
  end
end
