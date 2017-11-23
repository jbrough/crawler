require 'minitest/autorun'

require './test/helpers/fake_get'
require './test/helpers/fake_queue'

def file_fixture(name)
  File.read(Rails.root.to_s + "/test/fixtures/files/#{name}")
end

class TestStats < Minitest::Test
  def setup
    @get = FakeGet.new(file_fixture('alexa_siteinfo.html'))
    @queue = FakeQueue.new
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
