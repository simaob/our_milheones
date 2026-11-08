class CreateWeeks < ActiveRecord::Migration[4.2]
  def change
    create_table :weeks do |t|
      t.integer :number
      t.date :friday
      t.json :solution

      t.timestamps null: false
    end
  end
end
