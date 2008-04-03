class Flickr::Uploader < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  # upload a photo to flickr
  # 
  # Params
  # * filename (Required)
  #     path to the file to upload
  # * options (Optional)
  #     options to attach to the photo (See Below)
  # 
  # Options
  # * title (Optional)
  #     The title of the photo.
  # * description (Optional)
  #     A description of the photo. May contain some limited HTML.
  # * tags (Optional)
  #     A space-seperated list of tags to apply to the photo.
  # * privacy (Optional)
  #     Specifies who can view the photo. valid valus are:
  #       :public
  #       :private
  #       :friends
  #       :family
  #       :friends_and_family
  # * safety_level (Optional)
  #     sets the safety level of the photo. valid values are:
  #       :safe
  #       :moderate
  #       :restricted
  # * content_type (Optional)
  #     tells what type of image you are uploading. valid values are:
  #       :photo
  #       :screenshot
  #       :other
  # * hidden (Optional)
  #     boolean that determines if the photo shows up in global searches
  # 
  def upload(filename, options = {})
    photo = File.new(filename, 'r').read

    upload_options = {}
    @flickr.sign_request(upload_options)

    params = [file_to_multipart('photo',File.join(Dir.pwd, filename),'image/gif',photo)]
    
    upload_options.each do |k,v|
      params << text_to_multipart(k.to_s, v.to_s)
    end
    
    boundary = '7d44e178b043456ytghbvf'
    query = params.collect {|p| '----------' + boundary + "\r\n" + p}.join('') + "----------" + boundary + "--\r\n"
    
    rsp = Net::HTTP.start('api.flickr.com').post2("/services/upload/", query, "Content-type" => "multipart/form-data; boundary=" + boundary).body
    
    xm = XmlMagic.new(rsp)
    
    if xm[:stat] == 'ok'
      xm
    else
      raise "#{xm.err[:code]}: #{xm.err[:msg]}"
    end
  end

  private
  def text_to_multipart(key,value)
    return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"\r\n" + 
    "\r\n" + 
    "#{value}\r\n"
  end
  
  def file_to_multipart(key,filename,mime_type,content)
    return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"; filename=\"#{filename}\"\r\n" +
    "Content-Transfer-Encoding: binary\r\n" +
    "Content-Type: #{mime_type}\r\n" + 
    "\r\n" + 
    "#{content}\r\n"
  end
end