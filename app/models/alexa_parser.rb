class AlexaParser

  Stat = Struct.new(:country, :percent)

  def initialize(html_doc)
    @doc = Nokogiri::HTML(html_doc)
  end

  def country_stats
    node = @doc.at_css('#demographics_div_country_table tbody')
    node.css('tr').map do |tr|
      Stat.new(
        tr.at_css('a')['href'].split('/')[3],
        tr.at_css('span').content.to_f,
      )
    end
  end

end
