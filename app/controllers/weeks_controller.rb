class WeeksController < ApplicationController
  before_action :set_week, only: [:show, :destroy, :edit, :update, :request_bets]
  before_action :authorize!, only: [:edit, :update, :destroy, :request_bets]

  # GET /weeks
  # GET /weeks.json
  def index
    @weeks = Week.order('friday DESC').includes(:bets)
  end

  # GET /weeks/1
  # GET /weeks/1.json
  def show
    @users = User.order(:name)
    @bets = @week.bets.joins(:user).order('users.name ASC')
  end

  def edit
    @week.update_type = params[:update_type]
  end

  def update
    respond_to do |format|
      if @week.update(week_params)
        @week.register_prize if @week.update_type == 'prize'
        format.html { redirect_to @week, notice: 'Week was successfully updated.' }
        format.json { render :show, status: :ok, location: @week }
      else
        format.html { render :edit }
        format.json { render json: @week.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weeks/1
  # DELETE /weeks/1.json
  def destroy
    @week.destroy
    respond_to do |format|
      format.html { redirect_to weeks_url, notice: 'Week was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def request_bets
    BetMailer.make_your_bets(@week).deliver_later
    render nothing: true
  end

  def fill_bets
    @week = current_week
    User.all.each do |user|
      unless @week.bets.where(user_id: user.id).any?
        Bet.create_random_bet_for(user, @week)
      end
    end
    redirect_to @week
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_week
      @week = Week.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def week_params
      params.require(:week).permit(:number, :friday, :prize, :update_type,
                                   :prize_details, solution: [ :numbers, :stars])
    end
end
