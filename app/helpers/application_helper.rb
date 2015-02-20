module ApplicationHelper

  def print_bet bet
    return "" unless bet
    "#{bet["numbers"].join(", ")} + #{bet["stars"].join(", ")}"
  end
end
