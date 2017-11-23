require 'minitest/autorun'

def html
  '
  <html>
    <a href="/qux1" />
    <a href="/qux1" />
    <a href="//bad-link" />
    <a href="https://foo.bar.com/qux2" />
    <a href="http://foo.bar.com/qux2" />
    <a href="http://foo.bar.com/qux2" />
    <a href="http://bar.com/qux3" />
    <a href="http://foo.com/bar" />
    <a href="http://foo.com/bar" />
    <a href="http://baz.com/bar" />
  </html>
  '
end

class TestLinkExtractor < Minitest::Test
  def test_domain
    subj = LinkExtractor.new(URI.parse('http://foo.bar.com'), html)

    assert_equal 'bar.com', subj.domain
  end

  def test_internal_links
    subj = LinkExtractor.new(URI.parse('http://foo.bar.com'), html)

    expected = [
      'http://foo.bar.com/qux1',
      'https://foo.bar.com/qux2',
      'http://foo.bar.com/qux2',
      'http://bar.com/qux3',
    ]

    assert_equal expected, subj.internal_links
  end

  def test_external_links
    subj = LinkExtractor.new(URI.parse('http://bar.com'), html)

    expected = [
      'http://foo.com/bar',
      'http://baz.com/bar',
    ]

    assert_equal expected, subj.external_links
  end
end
