module Flickr
  def self.new(*params)
    Flickr::Base.new(*params)
  end
  
  class Base
    ENDPOINT = 'http://api.flickr.com/services/rest/'
    
    # create a new flickr object
    # 
    # Params
    # * api_key (Required)
    # * api_secret (Optional)
    def initialize(api_key, api_secret = nil)
      @api_key = api_key
      @api_secret = api_secret
    end

    def send_request(method, options = {})
      options.merge!(:api_key => @api_key, :method => method)
      options.merge!(:api_sig => Digest::MD5.hexdigest(@api_secret + options.keys.sort_by{|k| k.to_s}.collect{|k| k.to_s + options[k]}.join)) if @api_secret

      api_call = ENDPOINT + "?" + options.collect{|k,v| "#{k}=#{v}"}.join('&')
      rsp = open(api_call).read
      xm = XmlMagic.new(rsp)
      
      if xm[:stat] == 'ok'
        xm
      else
        raise "#{xm.err[:code]}: #{xm.err[:msg]}"
      end
    end

    def photos() @photos ||= Photos.new(self) end
  end
end