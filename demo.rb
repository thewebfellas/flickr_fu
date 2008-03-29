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
  puts "comments: #{photo.comments.size}"
  photo.comments.each do |comment|
    intro = "#{comment.author_name} says - "
    puts "#{intro}\"#{comment.comment.gsub("\n", "\n"+(" "*intro.length))}\""
  end
  puts "notes: #{photo.notes.size}"
  photo.notes.each do |note|
    puts "[#{note.x},#{note.y} ~ #{note.width}x#{note.height}] - \"#{note.note}\""
  end
  puts
  puts
end