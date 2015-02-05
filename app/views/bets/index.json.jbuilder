json.array!(@bets) do |bet|
  json.extract! bet, :id, :bet, :user_id
  json.url bet_url(bet, format: :json)
end
