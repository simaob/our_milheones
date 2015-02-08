class RenamePaymentsToTransactions < ActiveRecord::Migration
  def change
    rename_table :payments, :transactions
  end
end
