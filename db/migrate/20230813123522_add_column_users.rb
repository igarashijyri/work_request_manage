class AddColumnUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :name
      t.boolean :admin, default: false, null: false
    end
  end
end
