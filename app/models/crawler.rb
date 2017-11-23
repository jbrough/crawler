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
        @queue.enqueue(LinkRepository, @id, parser.domain, link, is_internal)
        if is_internal
          if !is_visited
            @queue.enqueue(Crawler, @id, link)
          end
        end
      end
    end && true
  end

  def is_visited
    # TODO: consider just using the URI with a TTL.
    set = "crawl:#{@id}"
    if @queue.redis.sismember(set, @uri.to_s)
      true
    else
      @queue.redis.sadd(set, @uri.to_s)
      false
    end
  end
end
