class Comment < ActiveRecord::Base
  DEFAULT_LIMIT = 15
  has_rakismet :only => :create, :content => :body

  attr_accessor         :openid_error
  attr_accessor         :openid_valid

  belongs_to            :post

  before_create         :default_status
  before_save           :apply_filter
  after_save            :denormalize
  after_destroy         :denormalize

  validates_presence_of :author, :body, :post

  named_scope           :latests, :order => "comments.updated_at DESC", 
    :limit => DEFAULT_LIMIT,
    :joins => [:post], :conditions => ['comments.akismet = ?', 'ham'],
    :select => "comments.id, comments.post_id, comments.body, comments.author, comments.created_at, posts.published_at"

  # validate :open_id_thing
  def validate
    super
    errors.add(:base, openid_error) unless openid_error.blank?
  end
  
  def default_status
    self.akismet = Enki::Config.default[:comment_start_as] || 'ham'
  end

  def apply_filter
    self.body_html = Lesstile.format_as_xhtml(self.body, :code_formatter => Lesstile::CodeRayFormatter)
    self.author_email = "" unless self.author_email
    self.author_url = "" unless self.author_url
  end

  def blank_openid_fields
    self.author_url = ""
    self.author_email = ""
  end

  def requires_openid_authentication?
    !!self.author.index(".")
  end

  def trusted_user?
    false
  end

  def user_logged_in?
    false
  end

  def approved?
    true
  end

  def denormalize
    self.post.denormalize_comments_count!
  end

  def destroy_with_undo
    undo_item = nil
    transaction do
      self.destroy
      undo_item = DeleteCommentUndo.create_undo(self)
    end
    undo_item
  end

  # Delegates
  def post_title
    post.title
  end

  class << self
    def protected_attribute?(attribute)
      [:author, :body].include?(attribute.to_sym)
    end

    def new_with_filter(params)
      comment = Comment.new(params)
      comment.created_at = Time.now
      comment.apply_filter
      comment
    end

    def build_for_preview(params)
      comment = Comment.new_with_filter(params)
      if comment.requires_openid_authentication?
        comment.author_url = comment.author
        comment.author     = "Your OpenID Name"
      end
      comment
    end

    def find_recent(options = {})
      find(:all, {
        :limit => DEFAULT_LIMIT,
        :order => 'created_at DESC'
      }.merge(options))
    end
  end
end
