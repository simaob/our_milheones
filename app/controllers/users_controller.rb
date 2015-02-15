class UsersController < ApplicationController

  before_filter :authorize!, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_password, only: [:create]

  def index
    @users = User.order(:name)
  end

  def new
    @user = User.new
  end

  def edit
    authorize! if @user != current_user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize! if @user != current_user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @bets = @user.bets.joins(:week).order('weeks.friday DESC').limit(5)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def set_password
    params[:user][:password] = params[:user][:password_confirmation] = "12345678"
  end
end
