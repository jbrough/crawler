require 'open-uri'
require 'public_suffix'
require 'resque'
require 'securerandom'

class Crawler
  @queue = :crawl_links

  def self.build(url, id = nil)
    new(id || SecureRandom.uuid, url, GetURL, Resque)
  end

  def self.perform(id, url)
    build(url, id).perform
  end

  def initialize(id, url, get, queue)
    @id = id
    @uri = URI.parse(url)
    @get, @queue = get, queue
  end

  def perform
    parser = LinkExtractor.new(@uri, @get.do(@id, @uri))

    [:internal_links, :external_links].each_with_index do |method, i|
      parser.send(method).each do |link|
        is_internal = i == 0
        if !is_visited(link)
          @queue.enqueue(LinkRepository, @id, parser.domain, link, is_internal)
          if is_internal
            @queue.enqueue(Crawler, @id, link)
          end
        end
      end
    end && true
  end

  def is_visited(link)
    # TODO: consider just using the URI with a TTL.
    set = "crawl:#{@id}"
    if @queue.redis.sismember(set, link)
      true
    else
      @queue.redis.sadd(set, link)
      false
    end
  end
end
