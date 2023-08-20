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

  def start_time
    work_member.order(start_time: "ASC").first.start_time.strftime('%Y年%m月%d日 %H時%M分')
  end

  def end_time
    work_member.order(end_time: "ASC").first.end_time.strftime('%Y年%m月%d日 %H時%M分')
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

  #NOTE: 最終的に最大何件送られてくるかは2023年8/16時点では決まってない
  def user_ids
    user_ids = []

    (1..5).each do |i|
      break if member_infos["user_id_#{i}"].nil?
      user_ids.push(member_infos["user_id_#{i}"])
    end

    user_ids
  end

  def create_work_member_info
    start_time = WorkMember.normalize_datetime(member_infos[:start_time_list])
    end_time = WorkMember.normalize_datetime(member_infos[:end_time_list])

    user_ids.each do |id|
      work_member_info_map = { :user_id => id, :start_time => start_time, :end_time => end_time, :overtime_work_info_id => self.id }
      WorkMember.new(work_member_info_map).save!
    end

    raise # 保存させないため一時的に。
  end

  def leader?(user_id)
    return user_id == leader_user_id
  end

  def manager?(user_id)
    return user_id == manager_user_id
  end
end