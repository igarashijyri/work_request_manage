class CreateWorkMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :work_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :overtime_work_info, null: false, foreign_key: true

      t.timestamps
    end
  end
end
