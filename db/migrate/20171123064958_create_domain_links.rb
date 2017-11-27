class CreateDomainLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :domain_links do |t|
      t.string :domain
      t.string :link
      t.boolean :internal
      t.datetime :created_at
    end
  end
end
