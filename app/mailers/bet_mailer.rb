# encoding: utf-8
class BetMailer < ApplicationMailer
  helper ApplicationHelper

  def new_week_created week
    @week = week
    mail(to: User.order(:name).map(&:email).join(","),
         subject: "[Euromilhões] #{@week.friday.to_fs}")
  end

  def bet_reminder week
    @week = week
    @quote = random_quote
    mail(to: @week.users_missing_bets.map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday.to_fs}")
  end

  def prize_won week
    @week = week
    @quote = random_quote
    mail(to: User.order(:name).map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday.to_fs}")
  end

  def bets_made week
    @week = week
    @quote = random_quote
    mail(to: User.order(:name).map(&:email).join(","),
         subject: "Re: [Euromilhões] #{@week.friday.to_fs}")
  end

  # Sent two days before the end of each month (see MonthlyBetsReminderJob).
  # `month` is the first day of the month the bets are for.
  def monthly_bets_reminder month
    @month = month.strftime("%B %Y")
    admins = User.where(is_admin: true).pluck(:email)
    return if admins.empty?

    mail(to: admins.join(","), subject: "[Euromilhões] Bets for #{@month}")
  end
end

