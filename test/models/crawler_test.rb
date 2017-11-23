require 'minitest/autorun'

require './test/helpers/fake_get'
require './test/helpers/fake_queue'

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

    @get = FakeGet.new(html)
    @queue = FakeQueue.new
    @subj = Crawler.new('uuid', url, @get, @queue)
  end

  def test_perform
    @subj.perform

    assert_equal 1, @get.calls, 'makes http call'
    assert_equal 6, @queue.calls, 'makes calls to enqueue'

    assert_equal(
      [LinkRepository, 'uuid', 'bar.com', 'http://bar.com/qux1', true],
      @queue.args[0],
      'adds internal links to persistence queue'
    )

    assert_equal(
      [LinkRepository, "uuid", "bar.com", "http://baz.com/bar", false],
      @queue.args[5],
      'adds external links to persistence queue'
    )
  end
end
