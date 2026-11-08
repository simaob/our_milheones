class RenamePaymentsToTransactions < ActiveRecord::Migration[4.2]
  def change
    rename_table :payments, :transactions
  end
end
