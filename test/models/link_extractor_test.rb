require 'minitest/autorun'

def html
  '
  <html>
    <a href="/qux1" />
    <a href="/qux1" />
    <a href="https://foo.bar.com/qux2" />
    <a href="http://foo.bar.com/qux2" />
    <a href="http://foo.bar.com/qux2" />
    <a href="http://foo.com/bar" />
    <a href="http://foo.com/bar" />
    <a href="http://baz.com/bar" />
  </html>
  '
end

class TestLinkExtractor < Minitest::Test
  def setup
    @subj = LinkExtractor.new(html)
  end

  def test_internal_links
    expected = [
      'http://foo.bar.com/qux1',
      'https://foo.bar.com/qux2',
      'http://foo.bar.com/qux2',
    ]

    assert_equal expected, @subj.internal_links(URI.parse('http://foo.bar.com'))
  end

  def test_external_links
    expected = [
      'http://foo.com/bar',
      'http://baz.com/bar',
    ]

    assert_equal expected, @subj.external_links(URI.parse('https://bar.com'))
  end
end
