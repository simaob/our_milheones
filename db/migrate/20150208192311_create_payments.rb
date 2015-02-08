class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float :value
      t.integer :user_id
      t.text :details
      t.date :date

      t.timestamps null: false
    end
  end
end
