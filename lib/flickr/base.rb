module Flickr
  def self.new(*params)
    Flickr::Base.new(*params)
  end
  
  class Base
    attr_reader :api_key, :api_secret, :token_cache
    
    REST_ENDPOINT = 'http://api.flickr.com/services/rest/'
    AUTH_ENDPOINT = 'http://flickr.com/services/auth/'
    
    # create a new flickr object
    # 
    # Params
    # * api_key (Required)
    #     The api key given to you by flickr.
    # * api_secret (Optional)
    #     The api secret given to you by flickr. This is used to generate a signiture for signed request.
    # * token_cache (Optional)
    #     File path to a cache file that holds a flickr token.
    # 
    def initialize(api_key, api_secret = nil, token_cache = nil)
      @api_key = api_key
      @api_secret = api_secret
      @token_cache = token_cache
    end

    def send_request(method, options = {})
      options.merge!(:api_key => @api_key, :method => method)
      sign_request(options)

      api_call = REST_ENDPOINT + "?" + options.collect{|k,v| "#{k}=#{v}"}.join('&')
      rsp = open(api_call).read
      xm = XmlMagic.new(rsp)
      
      if xm[:stat] == 'ok'
        xm
      else
        raise "#{xm.err[:code]}: #{xm.err[:msg]}"
      end
    end
    
    def sign_request(options, authorize = true)
      options.merge!(:auth_token => self.auth.token) if authorize and self.auth.token
      options.merge!(:api_sig => Digest::MD5.hexdigest(@api_secret + options.keys.sort_by{|k| k.to_s}.collect{|k| k.to_s + options[k].to_s}.join)) if @api_secret
    end

    def photos() @photos ||= Photos.new(self) end
    def auth() @auth ||= Auth.new(self) end
  end
end