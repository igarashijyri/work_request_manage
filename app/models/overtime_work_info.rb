class OvertimeWorkInfo < ApplicationRecord
  belongs_to :user
  has_many :work_member

  attr_reader :member_infos, :error_message

  def initialize(params)
    @job_num = params[:job_num]
    @reason = params[:reason]
    @leader_user_id = params[:leader_user_id]
    @user_id = params[:user_id]

    super
  end

  def request_create!(member_infos)
    @member_infos = member_infos

    begin
      ActiveRecord::Base.transaction do
        self.save!
        create_work_member_info
      end
    rescue => e
      @error_message = 'データが正しくありません。'
    end
  end

  def request_judge_authority?(user_id)
    return true if leader?(user_id) && leader_judge_status.nil?
    return true if manager?(user_id)
    
    false
  end

  def request_update(judge_info_map)
    user_id = judge_info_map[:current_user_id]
    manager_id = judge_info_map[:manager_user_id]
    judge = judge_info_map[:judge]

    set_manger_user_id(manager_id)
    change_judge_status(user_id, judge)
    
    @error_message = 'データの更新に失敗しました。' unless save
  end

  private

  # REFACTOR: 最終判断者かリーダー判断かのみを条件文にして、他の比較については別途切り出したい
  def change_judge_status(user_id, judge)
    if leader?(user_id) && leader_judge_status.nil? && manager_user_id.nil?
      ultimate_judge_status = judge
    elsif leader?(user_id) && leader_judge_status.nil? && manager_user_id.present?
      leader_judge_status = judge
    elsif manager?(user_id) && ultimate_judge_status.nil?
      ultimate_judge_status = judge
    end
  end

  def set_manger_user_id(manager_id)
    manager_user_id = manager_id
  end

  def create_work_member_info
    start_time_list = WorkMember.normalize_datetime(member_infos[:start_time_list])
    end_time_list = WorkMember.normalize_datetime(member_infos[:end_time_list])
    member_num = start_time_list.length #TODO: 本当はユーザidを配列で受け取り、その件数を取りたい。
    member_id = member_infos[:user_id]

    member_num.times do |i|
      start_time = start_time_list[i]
      end_time = end_time_list[i]
      work_member_info_map = { :user_id => member_id, :start_time => start_time, :end_time => end_time, :overtime_work_info_id => self.id }

      WorkMember.new(work_member_info_map).save!
    end
  end

  def leader?(user_id)
    return user_id == leader_user_id
  end

  def manager?(user_id)
    return user_id == manager_user_id
  end
end