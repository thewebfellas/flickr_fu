require 'lib/flickr'

flickr = Flickr::Base.new('bb662c756a830975d00b8277bff70ddf')

photos = flickr.photos.search(:tags => 'traingo')
