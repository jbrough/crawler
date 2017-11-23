class GetURL
  def self.do(uri)
    open(uri.to_s).read
  end
end
