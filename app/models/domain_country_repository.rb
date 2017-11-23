class DomainCountryRepository
  @queue = :save_stats

  def self.perform(params)
		ActiveRecord::Base.transaction do
	    DomainCountry.where(
				domain: params['domain'],
				country: params['country'],
			).delete_all

			DomainCountry.create(params)
		end
  end
end
