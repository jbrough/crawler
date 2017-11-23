require 'public_suffix'

class LinkExtractor
  attr_accessor :domain

  def initialize(uri, html_doc)
    @uri = uri
    @doc = Nokogiri::HTML(html_doc)
    @domain = PublicSuffix.parse(uri.host).domain
  end

  def internal_links
    uris.map do |u|
      if !u.host
        u.host = @uri.host
        u.scheme = @uri.scheme
        u.to_s
      else
        domain = parse_domain(u.host)

        u.to_s if domain && domain == @domain
      end
    end.compact.uniq
  end

  def external_links
    uris.map do |u|
      if u.host
        domain = parse_domain(u.host)
        u.to_s if domain && domain != @domain
      end
    end.compact.uniq
  end

  private

  def parse_domain(host)
    begin
      domain = PublicSuffix.parse(host).domain
    rescue PublicSuffix::DomainNotAllowed => e
      return nil
    end
  end

  def uris
    @doc.css('a').map {|a| URI(a['href']) }
  end
end
