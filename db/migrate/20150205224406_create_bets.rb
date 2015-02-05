class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.json :bet
      t.integer :user_id
      t.integer :week_id

      t.timestamps null: false
    end
  end
end
