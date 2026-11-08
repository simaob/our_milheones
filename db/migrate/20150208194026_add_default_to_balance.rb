class AddDefaultToBalance < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :balance, 0.0
  end
end
