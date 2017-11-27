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
    @queue = FakeQueue.new(false)
    @subj = Crawler.new('uuid', url, @get, @queue)
  end

  def test_perform
    @subj.perform

    # refactor the fake queue so we can key calls to enqueue by class rather
    # than index. Break up these tests.

    assert_equal(1, @get.calls, 'makes http call')
    assert_equal(10, @queue.calls[:enqueue].length, 'makes calls to enqueue')

    assert_equal(
      [LinkRepository, 'uuid', 'bar.com', 'http://bar.com/qux1', true],
      @queue.calls[:enqueue][0],
      'adds internal link to persistence queue'
    )

    assert_equal(
      [Crawler, "uuid", "http://bar.com/qux1"],
      @queue.calls[:enqueue][1],
      'adds internal link to crawl queue'
    )

    assert_equal(
      [LinkRepository, "uuid", "bar.com", "http://baz.com/bar", false],
      @queue.calls[:enqueue][9],
      'adds external link to persistence queue'
    )
  end
end
