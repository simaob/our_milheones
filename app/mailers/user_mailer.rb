class UserMailer < ApplicationMailer

  def user_created user, password
    @user = user
    @password = password
    mail(to: @user.email, subject: "[Euromilhões] Conta criada")
  end
end
