class Websites

  def self.links
    ActiveRecord::Base.connection.select_all('
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
      GROUP BY correlation_id, internal
    ')
  end
end
