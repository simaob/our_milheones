class TransactionKind < EnumerateIt::Base
  associate_values(
    bet: 0, payment: 1, admin: 2, prize: 3
  )
end
