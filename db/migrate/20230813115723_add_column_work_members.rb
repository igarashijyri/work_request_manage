class AddColumnWorkMembers < ActiveRecord::Migration[7.0]
  def change
    change_table :work_members do |t|
      t.datetime :start_time
      t.datetime :end_time
    end
  end

  add_foreign_key :work_members, :overtime_work_infos
end
