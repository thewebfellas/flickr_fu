module Flickr
  class Base
    ENDPOINT = 'http://api.flickr.com/services/rest/'

    def initialize(api_key, api_secret = nil)
      @api_key = api_key
      @api_secret = api_secret
    end

    def send_request(method, options = {})
      options.merge!(:api_key => @api_key, :method => method)

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