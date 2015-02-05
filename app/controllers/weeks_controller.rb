class WeeksController < ApplicationController
  before_action :set_week, only: [:show, :destroy]

  # GET /weeks
  # GET /weeks.json
  def index
    @weeks = Week.order('friday DESC')
  end

  # GET /weeks/1
  # GET /weeks/1.json
  def show
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_week
      @week = Week.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def week_params
      params.require(:week).permit(:number, :friday, :solution_id)
    end
end
