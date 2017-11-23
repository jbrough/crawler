require 'minitest/autorun'

def file_fixture(name)
  File.read(Rails.root.to_s + "/test/fixtures/files/#{name}")
end

class TestCrawler < Minitest::Test
  def setup
    get = Struct.new(:foo) do
      attr_accessor :args, :calls
      def do(url)
        @args ||= []
        @args << url
        @calls ||= 0
        @calls += 1
        file_fixture('alexa_siteinfo.html')
      end
    end

    queue = Struct.new(:foo) do
      attr_accessor :args, :calls
      def enqueue(*args)
        @args ||= []
        @args << args
        @calls ||= 0
        @calls += 1
      end
    end

    @get = get.new(1)
    @queue = queue.new(1)
    @subj = Stats.new('http://www.foo.com', @get, @queue)
  end

  def test_perform
    @subj.perform

    assert_equal 1, @get.calls, 'makes single http call'
    assert_equal(
      URI('https://www.alexa.com/siteinfo/foo.com'),
      @get.args[0],
      'visits alexa url for given domain stats'
    )
    assert_equal 5, @queue.calls, 'enqueues stats separately'

    assert_equal(
      [
				DomainCountryRepository,
        {country: 'US', percentage: 39.9, domain: 'foo.com'},
			],
      @queue.args[0],
      'adds country stat to persistence queue',
    )
  end
end
