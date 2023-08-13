class CreateOvertimeWorkInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :overtime_work_infos do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
