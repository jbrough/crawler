require 'public_suffix'

class LinkExtractor
  def initialize(html_doc)
    @doc = Nokogiri::HTML(html_doc)
  end

  def internal_links(uri)
    domain = PublicSuffix.parse(uri.host).domain

    uris.map do |u|
      if !u.host
        u.host = uri.host
        u.scheme = uri.scheme
        u.to_s
      elsif PublicSuffix.parse(u.host).domain == domain
        u.to_s
      end
    end.compact.uniq
  end

  def external_links(uri)
    domain = PublicSuffix.parse(uri.host).domain

    uris.map {|u|
      u.to_s if u.host && PublicSuffix.parse(u.host).domain != domain
    }.compact.uniq
  end

  private

  def uris
    @doc.css('a').map {|a| URI(a['href']) }
  end
end
