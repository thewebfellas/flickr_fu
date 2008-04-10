class Flickr::Uploader < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  # upload a photo to flickr
  # 
  # NOT WORKING ... FILE UPLOADS IN NET::HTTP SUX
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
    mimetype = MIME::Types.of(filename)

    upload_options = {}
    @flickr.sign_request(upload_options)
    
    form = Flickr::Uploader::MultiPartForm.new
        
    upload_options.each do |k,v|
      form.parts << Flickr::Uploader::FormPart.new(k.to_s, v.to_s)
    end
    
    form.parts << Flickr::Uploader::FormPart.new('photo', photo, mimetype, filename)
    
    headers = {"Content-Type" => "multipart/form-data; boundary=" + form.boundary}
		        
    rsp = Net::HTTP.start('api.flickr.com').post("/services/upload/", form.to_s, headers).body
        
    xm = XmlMagic.new(rsp)
    
    if xm[:stat] == 'ok'
      xm
    else
      raise "#{xm.err[:code]}: #{xm.err[:msg]}"
    end
  end
  
  # Returns information for the calling user related to photo uploads.
  # 
  # * Bandwidth and filesize numbers are provided in bytes.
  # * Bandwidth is specified in bytes per month.
  # * Pro accounts display 99 for the number of remaining sets, since they have unlimited sets. Free accounts will display either 3, 2, 1, or 0.
  # 
  def status
    rsp = @flickr.send_request('flickr.people.getUploadStatus')
    
    Flickr::Uploader::Status.new(@flickr, :nsid => rsp.user[:id],
                                          :is_pro => (rsp.user[:ispro] == "1" ? true : false),
                                          :username => rsp.user.username.to_s,
                                          :max_bandwidth => rsp.user.bandwidth[:maxbytes],
                                          :used_bandwidth => rsp.user.bandwidth[:usedbytes],
                                          :remaining_bandwidth => rsp.user.bandwidth[:remainingbytes],
                                          :max_filesize => rsp.user.filesize[:maxbytes],
                                          :max_videosize => rsp.user.videosize[:maxbytes],
                                          :sets_created => rsp.user.sets[:created].to_i,
                                          :sets_remaining => (rsp.user[:ispro] == "1" ? 99 : rsp.user.sets[:remaining].to_i))
  end
end

class Flickr::Uploader::FormPart
	attr_reader :data, :mime_type, :attributes, :filename

	def initialize(name, data, mime_type = nil, filename = nil)
		@attributes = {}
		@attributes['name'] = name
		@data = data
		@mime_type = mime_type
		@filename = filename
	end

	def to_s
		([ "Content-Disposition: form-data" ] +
		attributes.map{|k,v| "#{k}=\"#{v}\""}).
		join('; ') + "\r\n"+
		(@mime_type ? "Content-Type: #{@mime_type}\r\n" : '')+
		"\r\n#{data}"
	end
end

class Flickr::Uploader::MultiPartForm
	attr_accessor :boundary, :parts

	def initialize(boundary=nil)
		@boundary = boundary ||
		    "----------------------------Ruby#{rand(1000000000000)}"
		@parts = []
	end

	def to_s
		"--#@boundary\r\n"+
		parts.map{|p| p.to_s}.join("\r\n--#@boundary\r\n")+
		"\r\n--#@boundary--\r\n"
	end
end