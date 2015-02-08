module BetsHelper
  def display_bet bet, solution=nil
    return 'No bet made' unless bet
    result = []
    ['numbers', 'stars'].each do |i|
      sol = solution ? solution[i] : []
      tmp = []
      bet.send(i).each do |n|
        tmp << content_tag(:span, class: "#{sol.include?(n) ? "match" : ""}") do
            n.to_s
          end
      end
      result << tmp.join(", ")
    end
    result.join(" + ").html_safe
  end

  def display_user_of bet
    content_tag(:span, class: "#{bet.user == current_user ? "current-user" : ""}") do
      "#{bet.user.name}"
    end
  end
end
