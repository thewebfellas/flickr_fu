require 'lib/flickr'

flickr = Flickr::Base.new('bb662c756a830975d00b8277bff70ddf')

photos = flickr.photos.search(:tags => 'traingo', :per_page => 10)
puts photos.inspect
puts photos.next_page.inspect
puts photos.previous_page.inspect

while photos = photos.next_page
  puts photos.page
end