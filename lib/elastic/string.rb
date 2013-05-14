class String
  def tt(options={})
    I18n.translate(self, {:default=>self}.merge(options))
  end
end