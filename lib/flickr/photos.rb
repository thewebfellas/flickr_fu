class Flickr::Photos < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  def search(options)
    rsp = @flickr.send_request('flickr.photos.search', options)

    returning [] do |photos|
      rsp.photos.photo.each do |photo|
        photos << Photo.new(photo[:id], photo[:owner], photo[:secret], photo[:server], photo[:farm], photo[:title], photo[:ispublic], photo[:isfriend], photo[:isfamily])
      end
    end
  end

  class Photo < Struct.new(:id, :owner, :secret, :server, :farm, :title, :is_public, :is_friend, :is_family); end
end
