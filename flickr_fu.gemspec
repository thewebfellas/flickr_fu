Gem::Specification.new do |s|
  s.name     = "flickr_fu"
  s.version  = "0.1.5"
  s.date     = "2008-08-06"
  s.summary  = "Provides a ruby interface to flickr via the REST api"
  s.email    = "github@thewebfellas.com"
  s.homepage = "http://github.com/thewebfellas/flickr_fu"
  s.description = "Provides a ruby interface to flickr via the REST api"
  s.has_rdoc = true
  s.authors  = ["Ben Wyrosdick"]
  s.files    = [
    "README",
		"LICENSE",
		"Rakefile",
		"flickr_fu.gemspec",
		"lib/flickr/auth.rb",
		"lib/flickr/base.rb",
		"lib/flickr/comment.rb",
		"lib/flickr/license.rb",
		"lib/flickr/note.rb",
		"lib/flickr/people.rb",
		"lib/flickr/person.rb",
		"lib/flickr/photo.rb",
		"lib/flickr/photo_response.rb",
		"lib/flickr/photos.rb",
		"lib/flickr/size.rb",
		"lib/flickr/status.rb",
		"lib/flickr/test.rb",
		"lib/flickr/token.rb",
		"lib/flickr/uploader.rb",
		"lib/flickr_fu.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("mime-types", ["> 0.0.0"])
end