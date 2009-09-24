module DateHelper
  def format_month(date)
    date.try(:strftime, "%B %y")
  end
  
  def format_post_date(date)
    date.try(:strftime, "%B %d, %Y")
  end

  def format_comment_date(date)
    format_post_date(date) + " at " + date.strftime("%l:%M %p")
  end
end
