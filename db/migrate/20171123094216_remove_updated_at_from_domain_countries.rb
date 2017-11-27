class RemoveUpdatedAtFromDomainCountries < ActiveRecord::Migration[5.1]
  def up
    remove_column :domain_countries, :updated_at
  end
end
