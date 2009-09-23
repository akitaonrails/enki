module Admin::CommentsHelper
  def akismet_url(comment)
    if comment.akismet == 'ham'
      mark_as_spam_admin_comment_path(comment)
    else
      mark_as_ham_admin_comment_path(comment)
    end
  end
end