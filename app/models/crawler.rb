require 'open-uri'
require 'public_suffix'
require 'resque'

class Crawler
  def self.build(id, url)
    new(url, GetURL, Resque)
  end

  def initialize(id, url, get, queue)
    @id = id
    @uri = URI.parse(url)
    @get, @queue = get, queue
  end

  def perform
    parser = LinkExtractor.new(@uri, @get.do(@uri))

    [:internal_links, :external_links].each_with_index do |method, i|
      parser.send(method).each do |link|
        is_internal = i == 0
        @queue.enqueue(LinkRepository, id, parser.domain, link, is_internal)
      end

    end && true
  end
end
