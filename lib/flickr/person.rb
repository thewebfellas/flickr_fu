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
  #     a hash of attributes used to set the initial values of the person object
  def initialize(flickr, attributes)
    @flickr = flickr
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
  
  # Get a list of public photos for the given user.
  # 
  # Options
  # * safe_search (Optional)
  #     Safe search setting:
  #       1 for safe.
  #       2 for moderate.
  #       3 for restricted.
  #     (Please note: Un-authed calls can only see Safe content.)
  # * per_page (Optional)
  #     Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
  # * page (Optional)
  #     The page of results to return. If this argument is omitted, it defaults to 1.
  def public_photos(options = {})
    options.merge!({:user_id => self.nsid, :extras => "license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media"})

    rsp = @flickr.send_request('flickr.people.getPublicPhotos', options)

    returning Flickr::Photos::PhotoResponse.new(:page => rsp.photos[:page].to_i,
                                :pages => rsp.photos[:pages].to_i,
                                :per_page => rsp.photos[:perpage].to_i,
                                :total => rsp.photos[:total].to_i,
                                :photos => [],
                                :api => self,
                                :method => 'public_photos',
                                :options => options) do |photos|
      rsp.photos.photo.each do |photo|
        attributes = {:id => photo[:id], 
                      :owner => photo[:owner], 
                      :secret => photo[:secret], 
                      :server => photo[:server], 
                      :farm => photo[:farm], 
                      :title => photo[:title], 
                      :is_public => photo[:ispublic], 
                      :is_friend => photo[:isfriend], 
                      :is_family => photo[:isfamily],
                      :license => photo[:license],
                      :uploaded_at => (Time.at(photo[:dateupload].to_i) rescue nil),
                      :taken_at => (Time.parse(photo[:datetaken]) rescue nil),
                      :owner_name => photo[:ownername],
                      :icon_server => photo[:icon_server],
                      :original_format => photo[:originalformat],
                      :updated_at => (Time.at(photo[:lastupdate].to_i) rescue nil),
                      :geo => photo[:geo],
                      :tags => photo[:tags],
                      :machine_tags => photo[:machine_tags],
                      :o_dims => photo[:o_dims],
                      :views => photo[:views].to_i,
                      :media => photo[:media]}

        photos << Flickr::Photos::Photo.new(@flickr, attributes)
      end if rsp.photos.photo
    end
  end
end