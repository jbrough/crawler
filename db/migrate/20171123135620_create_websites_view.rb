class CreateWebsitesView < ActiveRecord::Migration[5.1]
  def up
    execute '
      CREATE VIEW websites AS
      SELECT domain
           , correlation_id
           , (SELECT
              COUNT (DISTINCT link)
              FROM domain_links
              WHERE correlation_id = dl.correlation_id
              AND internal = "t"
            ) AS num_internal_links
           , (SELECT
              COUNT (DISTINCT link)
              FROM domain_links
              WHERE correlation_id = dl.correlation_id
              AND internal = "f"
             ) AS num_external_links
      FROM domain_links dl
      GROUP BY correlation_id'
  end

  def down
    execute 'DROP VIEW websites'
  end
end
