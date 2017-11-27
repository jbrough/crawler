class FakeQueue
  attr_accessor :calls
  def initialize(sismember)
    @sismember = sismember
    @calls = {
      enqueue: [],
      redis: {
        sismember: [],
        sadd: [],
      },
    }
  end
  def enqueue(*args)
    @calls[:enqueue] << args
  end
  def redis
    self
  end
  def sismember(*args)
    @calls[:redis][:sismember] << args
    @sismember
  end
  def sadd(*args)
    @calls[:redis][:sadd] << args
    true
  end
end
