class AddColumnOvertimeWorkInfos < ActiveRecord::Migration[7.0]
  def change
    change_table :overtime_work_infos do |t|
      t.integer :job_num
      t.string :reason
      t.string :reject_reason
      t.string :leader_judge_status
      t.string :ultimate_judge_status, default: "確認中", null: false
      t.integer :leader_user_id, null: false
      t.integer :manager_user_id
    end

    add_foreign_key :overtime_work_infos, :users, column: :leader_user_id
    add_foreign_key :overtime_work_infos, :users, column: :manager_user_id
  end
end
