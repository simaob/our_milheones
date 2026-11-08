class AddUniqueIndexToWeeks < ActiveRecord::Migration[8.1]
  def change
    # Week.current can be called by a web request and the Monday job at the
    # same moment; the index makes sure only one of them creates the week.
    add_index :weeks, [:number, :friday], unique: true
  end
end
