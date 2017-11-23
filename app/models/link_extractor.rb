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
      elsif PublicSuffix.parse(u.host).domain == @domain
        u.to_s
      end
    end.compact.uniq
  end

  def external_links
    uris.map {|u|
      u.to_s if u.host && PublicSuffix.parse(u.host).domain != @domain
    }.compact.uniq
  end

  private

  def uris
    @doc.css('a').map {|a| URI(a['href']) }
  end
end
