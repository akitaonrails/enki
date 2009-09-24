class Post < ActiveRecord::Base
  DEFAULT_LIMIT = 30

  acts_as_taggable

  has_many                :comments, :dependent => :destroy
  has_many                :approved_comments, :class_name => 'Comment', :conditions => { :akismet => "ham" }

  before_validation       :generate_slug
  before_validation       :set_dates
  before_save             :apply_filter

  validates_presence_of   :title, :slug, :body

  validate                :validate_published_at_natural

  named_scope             :latests, :order => "published_at DESC", 
    :limit => DEFAULT_LIMIT,
    :select => "id, title, slug, published_at"
  
  named_scope             :archives, lambda { |params|
    beginning_of_month = if params && params[:year] && params[:month]
        Time.parse("#{params[:year]}-#{params[:month]}-01")
      else
        Time.now.beginning_of_month
      end
    end_of_month = beginning_of_month.end_of_month  
    { :conditions => ["published_at between ? and ?", beginning_of_month, end_of_month],
      :order => "published_at DESC",
      :select => "id, title, slug, published_at" }
  }
  
  def validate_published_at_natural
    errors.add("published_at_natural", "Unable to parse time") unless published?
  end

  attr_accessor :minor_edit
  def minor_edit
    @minor_edit ||= "1"
  end

  def minor_edit?
    self.minor_edit == "1"
  end
  
  def published?
    published_at?
  end

  attr_accessor :published_at_natural
  def published_at_natural
    @published_at_natural ||= published_at.send_with_default(:strftime, 'now', "%Y-%m-%d %H:%M")
  end

  class << self
    def build_for_preview(params)
      post = Post.new(params)
      post.generate_slug
      post.set_dates
      post.apply_filter
      TagList.from(params[:tag_list]).each do |tag|
        post.tags << Tag.new(:name => tag)
      end
      post
    end

    def find_recent(options = {})
      tag = options.delete(:tag)
      options = {
        :order      => 'posts.published_at DESC',
        :conditions => ['published_at < ?', Time.now],
        :limit      => DEFAULT_LIMIT
      }.merge(options)
      if tag
        find_tagged_with(tag, options)
      else
        find(:all, options)
      end
    end

    def find_by_permalink(year, month, day, slug, options = {})
      begin
        day = Time.parse([year, month, day].collect(&:to_i).join("-")).midnight
        post = find_all_by_slug(slug, options).detect do |post|
          [:year, :month, :day].all? {|time|
            post.published_at.send(time) == day.send(time)
          }
        end 
      rescue ArgumentError # Invalid time
        post = nil
      end
      post || raise(ActiveRecord::RecordNotFound)
    end

    def find_archives_links
      if connection.class.to_s =~ /SQLite3/
        connection.select_all("select count(*) as total, 
          strftime('%Y', published_at) as year, 
          strftime('%m', published_at) as month,
          strftime('%Y%m', published_at) as grouper
          from posts 
          group by year,month
          order by grouper DESC").
            map(&:symbolize_keys!)
      elsif connection.class.to_s =~ /Mysql/
        connection.select_all("select count(*) as total, 
          year(published_at) as year, 
          month(published_at) as month,
          date_format(published_at, '%Y%m') as grouper
          from posts 
          group by year,month
          order by grouper DESC").
            map(&:symbolize_keys!)
      end
    end    
  end

  def destroy_with_undo
    transaction do
      self.destroy
      return DeletePostUndo.create_undo(self)
    end
  end

  def month
    published_at.beginning_of_month
  end

  def apply_filter
    self.body_html = EnkiFormatter.format_as_xhtml(self.body)
    self.excerpt_html = EnkiFormatter.format_as_xhtml(self.excerpt)
  end

  def set_dates
    self.edited_at = Time.now if self.edited_at.nil? || !minor_edit?
    self.published_at = Chronic.parse(self.published_at_natural)
  end

  def denormalize_comments_count!
    Post.update_all(["approved_comments_count = ?", self.approved_comments.count], ["id = ?", self.id])
  end

  def generate_slug
    self.slug = self.title.dup if self.slug.blank?
    self.slug.slugorize!
  end

  # TODO: Contribute this back to acts_as_taggable_on_steroids plugin
  def tag_list=(value)
    value = value.join(", ") if value.respond_to?(:join)
    super(value)
  end
end
