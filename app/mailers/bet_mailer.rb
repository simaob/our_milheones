# encoding: utf-8
class BetMailer < ApplicationMailer

  def make_your_bets week
    @week = week
    mail(to: User.all.map(&:email).join(","),
         subject: "[Euromilhões] #{@week.friday}")
  end
end
