module Paperclip
  module Interpolations
    def year(attachment,style) 
      attachment.instance.created_at.year
    end
    def month(attachment,style) 
      attachment.instance.created_at.month
    end
    def day(attachment,style)
      attachment.instance.created_at.day
    end
  end
end