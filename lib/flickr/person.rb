# wrapping class to hold an flickr photo
# 
class Flickr::People::Person
  attr_accessor :username, :nsid, :is_admin, :is_pro, :icon_server, :icon_farm, :realname, :mbox_sha1sum, :location, :photos_url, :profile_url, :photo_count, :photo_first_upload, :photo_first_taken
    
  # create a new instance of a flickr person.
  # 
  # Params
  # * flickr (Required)
  #     the flickr object
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the photo object
  def initialize(flickr, attributes)
    @flickr = flickr
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end