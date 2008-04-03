class Flickr::Auth < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  # get or return a frob to use for authentication
  def frob
    @frob ||= get_frob
  end

  # generates the authorization url to allow access to a flickr account.
  # 
  # Params
  # * perms (Optional)
  #     sets the permision level to grant on the flickr account.
  #       :read - permission to read private information (DEFAULT)
  #       :write - permission to add, edit and delete photo metadata (includes 'read')
  #       :delete - permission to delete photos (includes 'write' and 'read')
  # 
  def url(perms = :read)
    options = {:api_key => @flickr.api_key, :perms => perms, :frob => self.frob}
    @flickr.sign_request(options)
    Flickr::Base::AUTH_ENDPOINT + "?" + options.collect{|k,v| "#{k}=#{v}"}.join('&')
  end

  # gets the token object for the current frob
  # 
  # Params
  # * pass_through (Optional)
  #     Boolean value that determines if a call will be made to flickr to find a taken for the current frob if empty
  # 
  def token(pass_through = true)
    @token ||= get_token(pass_through) rescue nil
  end

  # saves the current token to the cache file if token exists
  # 
  # Param
  # * filename (Optional)
  #     filename of the cache file. defaults to the file passed into Flickr.new
  # 
  def cache_token(filename = @flickr.token_cache)
    if filename and self.token
      cache_file = File.open(filename, 'w+')
      cache_file.puts self.token.to_yaml
      cache_file.close
      true
    else
      false
    end
  end

  private
  def get_frob
    rsp = @flickr.send_request('flickr.auth.getFrob')

    rsp.frob.to_s
  end

  def get_token(pass_through)
    if @flickr.token_cache and File.exists?(@flickr.token_cache)
      YAML.load_file(@flickr.token_cache)
    elsif pass_through
      rsp = @flickr.send_request('flickr.auth.getToken', {:frob => self.frob})

      Token.new(:token => rsp.auth.token.to_s, :permisions => rsp.auth.perms.to_s, :user_id => rsp.auth.user[:nsid], :username => rsp.auth.user[:username], :user_real_name => rsp.auth.user[:fullname])
    end
  end
end