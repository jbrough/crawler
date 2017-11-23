class RemoveUpdatedAtFromDomainCountries < ActiveRecord::Migration[5.1]
  def change
    remove_column :domain_countries, :updated_at
  end
end
