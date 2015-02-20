class AddDefaultBetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_bet, :json
  end
end
