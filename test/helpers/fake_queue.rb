class FakeQueue
  attr_accessor :args, :calls
  def enqueue(*args)
    @args ||= []
    @args << args
    @calls ||= 0
    @calls += 1
  end
end
