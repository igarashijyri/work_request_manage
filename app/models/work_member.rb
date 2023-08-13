class WorkMember < ApplicationRecord
  belongs_to :user
  belongs_to :overtime_work_info
end
