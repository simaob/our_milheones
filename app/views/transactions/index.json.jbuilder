json.array!(@payments) do |payment|
  json.extract! payment, :id, :value, :user_id, :details, :date
  json.url payment_url(payment, format: :json)
end
