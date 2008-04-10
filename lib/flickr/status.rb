# wrapper class to hold a flickr upload status object.
# 
class Flickr::Uploader::Status
  attr_accessor :nsid, :is_pro, :username, :max_bandwidth, :used_bandwidth, :remaining_bandwidth, :max_filesize, :max_videosize, :sets_created, :sets_remaining
  
  # create a new instance of a flickr upload status object.
  # 
  # Params
  # * flickr (Required)
  #     the flickr object
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the status object
  def initialize(flickr, attributes)
    @flickr = flickr
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end