require 'open-uri'
require 'public_suffix'
require 'resque'

class Stats
  SITEINFO_URL = 'https://www.alexa.com/siteinfo/'

  def self.build(url)
    new(url, GetURL, Resque)
  end

  def initialize(domain, get, queue)
    # guard against qualified domains being passed as
    # the uniq constraint is on tld.
    @domain = PublicSuffix.parse(URI(domain).host).domain

    @uri = URI(SITEINFO_URL + @domain)
    @get, @queue = get, queue
  end

  def perform
    parser = AlexaParser.new(@get.do(@uri))
    stats = parser.country_stats.map {|struct|
      struct.to_h.merge({domain: @domain})
    }

    @queue.enqueue(
      DomainCountryRepository, stats)
    true
  end
end
