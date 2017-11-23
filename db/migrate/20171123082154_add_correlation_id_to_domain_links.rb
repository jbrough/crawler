class AddCorrelationIdToDomainLinks < ActiveRecord::Migration[5.1]
  def change

    add_column :domain_links, :correlation_id, :string
  end
end
