class LinkRepository
  @queue = :save_links

  def self.perform(id, domain, link, is_internal)
    DomainLinks.create(
      correlation_id: id,
      domain: domain,
      link: link,
      internal: is_internal
    )
  end
end
