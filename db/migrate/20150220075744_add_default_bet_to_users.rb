class AddDefaultBetToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :default_bet, :json
  end
end
