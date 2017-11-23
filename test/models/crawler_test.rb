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

    get = Struct.new(:url) do
      attr_accessor :calls
      def do
        @calls ||= 0
        @calls += 1
        html
      end
    end

    enqueue = Struct.new(:foo) do
      attr_accessor :args, :calls
      def do(*args)
        @args ||= []
        @args << args
        @calls ||= 0
        @calls += 1
      end
    end

    @get = get.new(url)
    @enqueue = enqueue.new(1)
    @subj = Crawler.new(@get, @enqueue)
  end

  def test_process

    @subj.process

    assert_equal 1, @get.calls, 'makes http call'
    assert_equal 5, @enqueue.calls, 'makes calls to enqueue'

    assert_equal(
      [LinkRepository, 'bar.com', 'http://bar.com/qux1', true],
      @enqueue.args[0],
      'adds internal links to persistence queue'
    )

    assert_equal(
      [LinkRepository, 'bar.com', 'http://baz.com/bar', false],
      @enqueue.args[4],
      'adds external links to persistence queue'
    )
  end
end
