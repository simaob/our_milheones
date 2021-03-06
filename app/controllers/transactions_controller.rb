class TransactionsController < ApplicationController

  before_filter :authorize!, except: [:index]

  # GET /transactions
  # GET /transactions.json
  def index
    if current_user.is_admin?
      @transactions = Transaction.order('created_at DESC')
    else
      @transactions = current_user.transactions.order('created_at DESC')
    end
    @transactions = @transactions.page(params[:page])
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
    @users = User.order(:name)
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to transactions_path,
                      notice: 'Transaction was successfully created.' }
        format.json { render :show, status: :created, location: @transaction }
      else
        @users = User.order(:name)
        format.html { render :new }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:value, :user_id, :details, :date, :kind)
    end
end
