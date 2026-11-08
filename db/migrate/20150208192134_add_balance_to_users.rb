class AddBalanceToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :balance, :float
  end
end
