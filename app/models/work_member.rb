class WorkMember < ApplicationRecord
  belongs_to :user
  belongs_to :overtime_work_info

  def initialize(info_map)
    @user_id = info_map[:user_id]
    @overtime_work_info_id = info_map[:overtime_work_info_id]
    @start_time = info_map[:start_time]
    @end_time = info_map[:end_time]

    super
  end

  def self.normalize_datetime(time_list)
    time = time_list[0]
    yymmdd = time.values[0..2].join('-')
    hhmm = time.values[3..4].join(':')

    "#{yymmdd} #{hhmm}".to_datetime
  end
end