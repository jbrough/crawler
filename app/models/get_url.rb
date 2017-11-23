require 'ougai'

class GetURL
  Logger = Ougai::Logger.new(STDOUT)

  # TODO: pass in a correlation ID for logging
  def self.do(uri)
    t = Time.now
    req = Net::HTTP::Get.new(uri.to_s)
    res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
    }

    msg = {
      code: res.code,
      method: "GET",
      msec: ((Time.now - t) * 1000.0).to_i,
      url: uri.to_s,
    }

    if res.code > '308'
      Logger.error(msg)
    else
      Logger.info(msg)
    end

    res.body
  end
end
