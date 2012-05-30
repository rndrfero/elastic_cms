class String
  def tt
    I18n.translate(self, :default=>self)
  end
end