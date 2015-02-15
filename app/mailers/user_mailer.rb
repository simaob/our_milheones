class UserMailer < ApplicationMailer

  def welcome_email user, password
    @user = user
    @password = password
    mail(to: @user.email, subject: "[Euromilhões] Conta criada")
  end
end
