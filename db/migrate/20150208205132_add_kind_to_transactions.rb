class AddKindToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :kind, :integer, null: false
  end
end
