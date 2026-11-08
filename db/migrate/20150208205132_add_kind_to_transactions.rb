class AddKindToTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :transactions, :kind, :integer, null: false
  end
end
