require 'minitest/autorun'

def file_fixture(name)
  File.read(Rails.root.to_s + "/test/fixtures/files/#{name}")
end

class TestAlexaParser < Minitest::Test
  def setup
    @subj = AlexaParser.new(file_fixture('alexa_siteinfo.html'))
  end

  def test_country_stats
    actual = @subj.country_stats

    assert_equal 5, actual.length, 'total stats'
    assert_equal 'US', actual[0].country, 'country'
    assert_equal 39.9, actual[0].percent, 'percent'
    assert_equal 'GB', actual[1].country, 'country'
    assert_equal 7.5, actual[1].percent, 'percent'
  end
end
