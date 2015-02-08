class TransactionKind < EnumerateIt::Base
  associate_values :bet, :payment, :admin
end
