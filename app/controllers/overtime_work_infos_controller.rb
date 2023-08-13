class OvertimeWorkInfosController < ApplicationController
  def index
    @overtime_work_infos = OvertimeWorkInfo.all
  end

  def show
    @overtime_work_info = OvertimeWorkInfo.find(params[:id])
    @admin = @overtime_work_info.request_judge_authority?(current_user.id)
  end

  def new
    all_user = User.select(:id, :user)
    @admin_users = all_user.where(admin: true).pluck(:name, :id)
    @users = all_user.pluck(:name, :id)
  end

  def edit
    @overtime_work_info = OvertimeWorkInfo.find(params[:id])
    @admin_users = User.where(admin: true).pluck(:name, :id)
  end

  def create
    overtime_work_info = OvertimeWorkInfo.new(overtime_work_info_params)
    overtime_work_info.request_create!(work_member_params)

    respond_to do |format|
      if overtime_work_info.error_message.nil?
        format.html { redirect_to overtime_work_info, notice: "残業申請を作成しました。" }
      else
        format.html { redirect_to new_overtime_work_info_path, notice: "残業申請に失敗しました。" }
      end
    end
  end

  # 承認 / 却下押下時にステータスを変更する処理をいれる
  # リーダが許可/却下した場合、リーダはedit画面を表示できないようにする
  # 部門長が許可/却下した場合、部門長はedit画面を表示できないようにする
  # 理由を記述するフォームを生成する
  def update
    overtime_work_info = OvertimeWorkInfo.find(params[:id])
    overtime_work_info.request_update(update_params)

    respond_to do |format|
      if overtime_work_info.error_message.nil?
        format.html { redirect_to overtime_work_info, notice: "残業申請を作成しました。" }
      else
        format.html { redirect_to new_overtime_work_info_path, notice: "残業申請に失敗しました。" }
      end
    end
  end

  private

  def overtime_work_info_params
    params.require(:overtime_work_info).permit(:job_num, :reason, :leader_user_id).merge(user_id: current_user.id)
  end

  def work_member_params
    params.require(:overtime_work_info).permit(:user_id, start_time_list: datetime_keys, end_time_list: datetime_keys)
  end

  def update_params
    params.require(:judge_infos).permit(:manager_user_id, :reject_reason).merge(params.permit(:judge)).merge({ :current_user_id => current_user.id })
  end

  # REFACTOR: 本当はFormクラスでAttributeAssignmentを定義したい
  def datetime_keys
    return ["(1i)", "(2i)", "(3i)", "(4i)", "(5i)"]
  end
end