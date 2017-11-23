require 'ougai'

class GetURL
  Logger = Ougai::Logger.new(STDOUT)
  UA = 'Mozilla/5.0 (X11; CrOS x86_64 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36'

  def self.do(id, uri)
    t = Time.now

    res = nil
    tries = 0

    uri_string = uri.to_s

    loop do
      uri = URI.parse(uri_string)
      req = Net::HTTP::Get.new(uri.to_s, {'User-Agent': UA})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      res = http.request(req)

      if res['location']
        uri_string = res['location']

        # vice.com uses relative URIs in some Location headers.
        # This is allowed by the specification.
        #
        # TODO: consider using a library like restclient or extracting a
        # tried-and-tested implementation to use here.
        if uri_string[0] == '/'
          uri.path = uri_string
          uri_string = uri.to_s
        end
      end

      if !res.kind_of? Net::HTTPRedirection
        break
      end

      if tries == 10
        break
      end

      tries += 1
    end

    msg = {
      code: res.code,
      id: id,
      method: "GET",
      msec: ((Time.now - t) * 1000.0).to_i,
      url: uri.to_s,
      redirects: tries,
      redirects_exceeded: tries == 10,
    }

    if res.code > '308'
      Logger.error(msg)
    else
      Logger.info(msg)
    end

    res.body
  end
end
