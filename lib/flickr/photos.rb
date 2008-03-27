class Flickr::Photos < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  def search(options)
    rsp = @flickr.send_request('flickr.photos.search', options)

    returning PhotoResponse.new(rsp.photos[:page], rsp.photos[:pages], rsp.photos[:perpage], rsp.photos[:total], [], self, 'flickr.photos.search', options) do |photos|
      rsp.photos.photo.each do |photo|
        photos << Photo.new(photo[:id], photo[:owner], photo[:secret], photo[:server], photo[:farm], photo[:title], photo[:ispublic], photo[:isfriend], photo[:isfamily])
      end
    end
  end

  class PhotoResponse < Struct.new(:page, :pages, :per_page, :total, :photos, :api, :method, :options)
    def <<(photo)
      self.photos << photo
    end
    
    def each &block
      self.photos.each &block
    end
    
    def next_page
      api.send(self.method.split('.').last, options.merge(:page => self.page.to_i + 1)) if self.page.to_i < self.pages.to_i
    end
    
    def previous_page
      api.send(self.method.split('.').last, options.merge(:page => self.page.to_i - 1)) if self.page.to_i > 1
    end
  end
  
  class Photo < Struct.new(:id, :owner, :secret, :server, :farm, :title, :is_public, :is_friend, :is_family); end
end
