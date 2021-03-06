module ApplicationHelper

  def formatted_bet bet, solution=nil
    return 'No bet made' unless bet
    result = []
    ['numbers', 'stars'].each do |i|
      sol = solution ? solution[i] : []
      tmp = []
      bet.send(i).each do |n|
        tmp << content_tag(:span, class: "#{"match" if sol.include?(n)}") do
            n.to_s
          end
      end
      result << tmp.join(", ")
    end
    result.join(" + ").html_safe
  end

  def display_user user
    content_tag(:span, class: "#{"current-user" if user == current_user}") do
      "#{user.name}"
    end
  end

  def print_bet bet, char=","
    return "" unless bet
    "#{bet["numbers"].join("#{char} ")} + #{bet["stars"].join("#{char} ")}"
  end

  def balance balance
    number_with_precision(balance, precision: 2)
  end
end

