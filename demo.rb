require 'lib/ruby_flickr'

flickr = Flickr.new('bb662c756a830975d00b8277bff70ddf')

photos = flickr.photos.search(:tags => 'ruby-flickr')

puts "found #{photos.size} photo(s)"

photos.each do |photo|
  puts photo.title
  puts photo.description unless [nil, ''].include?(photo.description)
  [:square, :thumbnail, :small, :medium, :large, :original].each do |size|
    puts "#{size}: #{photo.url(size)}"
  end
  puts "comments: #{photo.comment_count}"
  photo.comments.each do |comment|
    puts comment.comment
  end
  puts
  puts
end