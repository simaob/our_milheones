module BetsHelper
  def display_bet bet, solution=nil
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
end
