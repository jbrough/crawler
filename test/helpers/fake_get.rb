class FakeGet
  attr_accessor :args, :calls
  def initialize(html = nil)
    @html = html
  end
  def do(id, url)
    @args ||= []
    @args << url
    @calls ||= 0
    @calls += 1

    @html
  end
end
