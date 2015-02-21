# encoding: utf-8
class BetMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def make_your_bets week
    @week = week
    @quote = random_quote
    mail(to: User.all.map(&:email).join(","),
         subject: "[Euromilhões] #{@week.friday}")
  end

  def prize_won week
    @week = week
    @quote = random_quote
    mail(to: User.all.map(&:email).join(","),
         subject: "[Euromilhões] #{@week.friday}")
  end
end
