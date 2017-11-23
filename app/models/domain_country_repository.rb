class DomainCountryRepository
  @queue = :save_stats

  def self.perform(params)
    DomainCountry.create(params)
  end
end
