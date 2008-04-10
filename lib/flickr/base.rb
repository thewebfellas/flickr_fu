module Flickr
  def self.new(*params)
    Flickr::Base.new(*params)
  end
  
  class Base
    attr_reader :api_key, :api_secret, :token_cache
    
    REST_ENDPOINT = 'http://api.flickr.com/services/rest/'
    AUTH_ENDPOINT = 'http://flickr.com/services/auth/'
    UPLOAD_ENDPOINT = 'http://api.flickr.com/services/upload/'
    
    # create a new flickr object
    # 
    # Params
    # * config_file (Required)
    #     yaml file to load configuration from
    # * token_cache (Optional)
    #     location of the token cache file. This will override the setting in the config file
    # 
    # Config Example (yaml file)
    # 
    # ---
    # key: YOUR_API_KEY
    # secret: YOUR_API_SECRET
    # token_cache: token.yml
    # 
    def initialize(config_file, token_cache = nil)
      config = YAML.load_file(config_file)
      
      @api_key = config['key']
      @api_secret = config['secret']
      @token_cache = token_cache || config['token_cache']
      
      raise 'flickr config file must contain an api key and secret' unless @api_key and @api_secret
    end

    # sends a request to the flcikr REST api
    # 
    # Params
    # * method (Required)
    #     name of the flickr method (ex. flickr.photos.search)
    # * options (Optional)
    #     hash of query parameters, you do not need to include api_key, api_sig or auth_token because these are added automatically
    # * http_method (Optional)
    #     choose between a GET and POST http request. Valid options are:
    #       :get (DEFAULT)
    #       :post
    # * endpoint (Optional)
    #     url of the api endpoint
    # 
    def send_request(method, options = {}, http_method = :get, endpoint = REST_ENDPOINT)
      options.merge!(:api_key => @api_key, :method => method)
      sign_request(options)
      
      if http_method == :get
        api_call = endpoint + "?" + options.collect{|k,v| "#{k}=#{v}"}.join('&')
        rsp = Net::HTTP.get(URI.parse(api_call))
      else
        rsp = Net::HTTP.post_form(URI.parse(REST_ENDPOINT), options).body
      end
      
      xm = XmlMagic.new(rsp)
      
      if xm[:stat] == 'ok'
        xm
      else
        raise "#{xm.err[:code]}: #{xm.err[:msg]}"
      end
    end
    
    # alters your api parameters to include a signiture and authorization token
    # 
    # Params
    # * options (Required)
    #     the hash of parameters to be passed to the send_request
    # * authorize (Optional)
    #     boolean value to determine if the call with include an auth_token (Defaults to true)
    # 
    def sign_request(options, authorize = true)
      options.merge!(:auth_token => self.auth.token(false).to_s) if authorize and self.auth.token(false)
      options.delete(:api_sig)
      options.merge!(:api_sig => Digest::MD5.hexdigest(@api_secret + options.keys.sort_by{|k| k.to_s}.collect{|k| k.to_s + options[k].to_s}.join)) if @api_secret
    end

    # creates and/or returns the Flickr::Photos object
    def photos() @photos ||= Photos.new(self) end
      
    # creates and/or returns the Flickr::People object
    def people() @people ||= People.new(self) end
      
    # creates and/or returns the Flickr::Auth object
    def auth() @auth ||= Auth.new(self) end
      
    # creates and/or returns the Flickr::Uploader object
    def uploader() @uploader ||= Uploader.new(self) end
  end
end