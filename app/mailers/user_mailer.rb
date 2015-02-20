# encoding: utf-8
class UserMailer < ApplicationMailer

  def welcome_email user, password
    @user = user
    @password = password
    @quote = random_quote
    mail(to: @user.email, subject: "[Euromilhões] Conta criada")
  end
end
