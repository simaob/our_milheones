class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.integer :number
      t.date :friday
      t.integer :solution_id

      t.timestamps null: false
    end
  end
end
