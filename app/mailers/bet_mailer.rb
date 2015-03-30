# encoding: utf-8
class BetMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def make_your_bets week
    @week = week
    @quote = random_quote
    mail(to: User.order(:name).map(&:email).join(","),
         subject: "[Euromilhões] #{@week.friday}")
  end

  def bet_reminder week
    @week = week
    @quote = random_quote
    mail(to: @week.users_missing_bets.map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday}")
  end

  def prize_won week
    @week = week
    @quote = random_quote
    mail(to: User.order(:name).map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday}")
  end

  def bets_made week
    @week = week
    @quote = random_quote
    mail(to: User.order(:name).map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday}")
  end

  def do_the_bets week
    @week = week
    mail(to: User.where(is_admin: true).map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday}")
  end
end

