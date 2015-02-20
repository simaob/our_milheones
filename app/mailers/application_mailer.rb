# encoding: utf-8
class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@simaobelchior.net"
  layout 'mailer'

  private

  def random_quote
    [
      "Quem tudo quer, tudo perde",
      "Não há fome que não dê em fartura",
      "Quem não tem cão, caça com gato",
      "Mais vale um pássaro na mão, do que dois a voar",
      "Enquanto há vida, há esperança",
      "Et pluribus unum",
      "Confia em ti",
      "Para a frente é que é caminho",
      "Sarava!",
      "Quando é que se abre a porta aBerta?",
      "Eu sou o rei dos matraquilhos"
    ].shuffle.first
  end
end
