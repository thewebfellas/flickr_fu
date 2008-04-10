# wrapping class to hold an flickr photo
# 
class Flickr::Photos::Photo
  attr_accessor :id, :owner, :secret, :server, :farm, :title, :is_public, :is_friend, :is_family # standard attributes
  attr_accessor :license, :uploaded_at, :taken_at, :owner_name, :icon_server, :original_format, :updated_at, :geo, :tags, :machine_tags, :o_dims, :views, :media # extra attributes
  attr_accessor :info_added, :description, :original_secret, :owner_username, :owner_realname, :url_photopage, :notes # info attributes
  attr_accessor :sizes_added, :sizes, :url_square, :url_thumbnail, :url_small, :url_medium, :url_large, :url_original # size attributes
  attr_accessor :comments_added, :comments # comment attributes
  
  # create a new instance of a flickr photo.
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

  # retreive the url to the image stored on flickr
  # 
  # == Params
  # * size (Optional)
  #     the size of the image to return. Optional sizes are:
  #       :square - square 75x75
  #       :thumbnail - 100 on longest side
  #       :small - 240 on longest side
  #       :medium - 500 on longest side
  #       :large - 1024 on longest side (only exists for very large original images)
  #       :original - original image, either a jpg, gif or png, depending on source format
  # 
  def url(size = :medium)
    attach_sizes
    send("url_#{size}")
  end

  # save the current photo to the local computer
  # 
  # == Params
  # * filename (Required)
  #     name of the new file omiting the extention (ex. photo_1)
  # * size (Optional)
  #     the size of the image to return. Optional sizes are:
  #       :small - square 75x75
  #       :thumbnail - 100 on longest side
  #       :small - 240 on longest side
  #       :medium - 500 on longest side
  #       :large - 1024 on longest side (only exists for very large original images)
  #       :original - original image, either a jpg, gif or png, depending on source format
  # 
  def save_as(filename, size = :medium)
    format = size.to_sym == :original ? self.original_format : 'jpg'
    filename = "#{filename}.#{format}"

    if File.exists?(filename) or not self.url(size)
      false
    else
      f = File.new(filename, 'w+')
      f.puts open(self.url(size)).read
      f.close
      true
    end
  end
  
  # Add tags to a photo.
  # 
  # Params
  # * tags (Required)
  #     comma seperated list of tags
  # 
  def add_tags(tags)
    rsp = @flickr.send_request('flickr.photos.addTags', {:photo_id => self.id, :tags => tags}, :post)
    true
  end
  
  # Add comment to a photo as the currently authenticated user.
  #
  # Params
  # * message (Required)
  #     text of the comment
  #
  def add_comment(message)
    rsp = @flickr.send_request('flickr.photos.comments.addComment', {:photo_id => self.id, :comment_text => message}, :post)
    true
  end
  
  # Add a note to a photo. Coordinates and sizes are in pixels, based on the 500px image size shown on individual photo pages.
  # 
  # Params
  # * message (Required)
  #     The text of the note
  # * x (Required)
  #     The left coordinate of the note
  # * y (Required)
  #     The top coordinate of the note
  # * w (Required)
  #     The width of the note
  # * h (Required)
  #     The height of the note
  #     
  def add_note(message, x, y, w, h)
    rsp = @flickr.send_request('flickr.photos.notes.add', {:photo_id => self.id, :note_x => x, :note_y => y, :note_w => w, :note_h => h, :note_text => message}, :post)
    true
  end
  
  def description # :nodoc:
    attach_info
    @description
  end

  def original_secret # :nodoc:
    attach_info
    @original_secret
  end

  def owner_username # :nodoc:
    attach_info
    @owner_username
  end

  def owner_realname # :nodoc:
    attach_info
    @owner_realname
  end

  def url_photopage # :nodoc:
    attach_info
    @url_photopage
  end

  def comments # :nodoc:
    attach_comments
    @comments
  end
  
  def sizes # :nodoc:
    attach_sizes
    @sizes
  end

  def notes # :nodoc:
    attach_info
    @notes
  end

  protected
  def url_square # :nodoc:
    attach_sizes
    @url_square
  end

  def url_thumbnail # :nodoc:
    attach_sizes
    @url_thumbnail
  end

  def url_small # :nodoc:
    attach_sizes
    @url_small
  end

  def url_medium # :nodoc:
    attach_sizes
    @url_medium
  end

  def url_large # :nodoc:
    attach_sizes
    @url_large
  end

  def url_original # :nodoc:
    attach_sizes
    @url_original
  end

  private
  attr_accessor :comment_count
  
  # convert the size to the key used in the flickr url
  def size_key(size)
    case size.to_sym
    when :square : 's'
    when :thumb, :thumbnail : 't'
    when :small : 'm'
    when :medium : '-'
    when :large : 'b'
    when :original : 'o'
    else ''
    end
  end

  # loads photo info when a field is requested that requires additional info
  def attach_info
    unless self.info_added
      rsp = @flickr.send_request('flickr.photos.getInfo', :photo_id => self.id, :secret => self.secret)

      self.info_added = true
      self.description = rsp.photo.description.to_s
      self.original_secret = rsp.photo[:originalsecret]
      self.owner_username = rsp.photo.owner[:username]
      self.owner_realname = rsp.photo.owner[:realname]
      self.url_photopage = rsp.photo.urls.url.to_s
      self.comment_count = rsp.photo.comments.to_s.to_i

      self.notes = []

      rsp.photo.notes.note.each do |note|
        self.notes << Flickr::Photos::Note.new(:id => note[:id],
                               :note => note.to_s,
                               :author => note[:author],
                               :author_name => note[:authorname],
                               :x => note[:x],
                               :y => note[:y],
                               :width => note[:w],
                               :height => note[:h])
      end if rsp.photo.notes.note
    end
  end

  # loads picture sizes only after one has been requested
  def attach_sizes
    unless self.sizes_added
      rsp = @flickr.send_request('flickr.photos.getSizes', :photo_id => self.id)

      self.sizes_added = true
      self.sizes = []

      rsp.sizes.size.each do |size|
        send("url_#{size[:label].downcase}=", size[:source])

        self.sizes << Flickr::Photos::Size.new(:label => size[:label],
                               :width => size[:width],
                               :height => size[:height],
                               :source => size[:source],
                               :url => size[:url])
      end
    end
  end

  # loads comments once they have been requested
  def attach_comments
    if @comment_count == 0
      self.comments = []
      self.comments_added = true
    elsif not self.comments_added
      rsp = @flickr.send_request('flickr.photos.comments.getList', :photo_id => self.id)

      self.comments = []
      self.comments_added = true

      rsp.comments.comment.each do |comment|
        self.comments << Flickr::Photos::Comment.new(:id => comment[:id],
                                     :comment => comment.to_s,
                                     :author => comment[:author],
                                     :author_name => comment[:authorname],
                                     :permalink => comment[:permalink],
                                     :created_at => (Time.at(comment[:datecreate].to_i) rescue nil))
      end
    end        
  end
end