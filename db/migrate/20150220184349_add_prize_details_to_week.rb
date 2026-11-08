class AddPrizeDetailsToWeek < ActiveRecord::Migration[4.2]
  def change
    add_column :weeks, :prize_details, :text
  end
end
