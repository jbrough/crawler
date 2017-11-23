require 'open-uri'
require 'public_suffix'

class Crawler
  def initialize(get, enqueue)
    @uri = URI.parse(get.url)
    @get, @enqueue = get, enqueue
  end

  def process
    parser = LinkExtractor.new(@uri, @get.do)

    [:internal_links, :external_links].each_with_index do |method, i|
      parser.send(method).each {|link|
        is_internal = i == 0
        @enqueue.do(LinkRepository, parser.domain, link, is_internal)
      }
    end
  end
end
