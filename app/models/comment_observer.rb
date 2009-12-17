class CommentObserver < ActiveRecord::Observer
  
  def after_save(comment)
    comment.post.update_attribute(:updated_at, Time.now)
  end
  
  def after_destroy(comment)
    comment.post.update_attribute(:updated_at, Time.now)
  end
  
end
