require 'minitest/autorun'

def html
  '
  <html>
    <a href="/qux1" />
    <a href="https://foo.bar.com/qux2" />
    <a href="http://foo.com/bar" />
    <a href="http://baz.com/bar" />
  </html>
  '
end

class TestCrawler < Minitest::Test
  def setup
    url = 'http://bar.com'

    # TODO: extract to a fakes lib as these are reused in other test
    get = Struct.new(:foo) do
      attr_accessor :args, :calls
      def do(url)
        @args ||= []
        @args << url
        @calls ||= 0
        @calls += 1
        html
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
    @subj = Crawler.new(url, @get, @queue)
  end

  def test_perform
    @subj.perform

    assert_equal 1, @get.calls, 'makes http call'
    assert_equal 6, @queue.calls, 'makes calls to enqueue'

    assert_equal(
      [LinkRepository, 'bar.com', 'http://bar.com/qux1', true],
      @queue.args[0],
      'adds internal links to persistence queue'
    )

    assert_equal(
      [LinkRepository, 'bar.com', 'http://foo.com/bar', false],
      @queue.args[4],
      'adds external links to persistence queue'
    )
  end
end
