atom_feed(
  :url         => formatted_comments_path(:format => 'atom', :only_path => false), 
  :root_url    => comments_path(:only_path => false),
  :schema_date => Time.now.year
) do |feed|
  feed.title     "Latest Comments from #{Enki::Config.default[:title]}"
  feed.updated   @comments.empty? ? Time.now.utc : @comments.select { |r| !r.created_at.nil? }.collect(&:created_at).max
  feed.generator Enki::Config.default[:title], "uri" => Enki::Config.default[:url]

  feed.author do |xml|
    xml.name  author.name
    xml.email author.email unless author.email.nil?
  end

  @comments.each do |comment|
   feed.entry(comment, :url => post_path(comment.post, :only_path => false) + "#comment-#{comment.id}", 
    :published => comment.created_at, :updated => comment.created_at) do |entry|
      entry.title   comment.post.title
      entry.content( "Commented by: #{comment.author}<br/></br/>" + (comment.body.nil? ? '' : comment.body), :type => 'html')
    end
  end
end
