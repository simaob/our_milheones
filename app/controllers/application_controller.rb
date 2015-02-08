class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def current_week
    @current_week ||= Week.find_or_create_by(
      number: friday.strftime("%U").to_i,
      friday: friday
    )
  end
  helper_method :current_week

  def friday
    Date.today.end_of_week
  end

  def authorize!
    unless current_user.is_admin?
      redirect_to request.referrer || root_url,
        alert: 'You are not authorized to view that page'
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end
end
