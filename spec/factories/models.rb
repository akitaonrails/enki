Factory.define(:post) do |p|
  p.title 'Foo'
  p.excerpt 'this is an excerpt'
  p.body 'this is a post'
  p.minor_edit 0
end

Factory.define(:comment) do |c|
  c.author 'John Doe'
  c.author_url ''
  c.author_email ''
  c.user_ip '127.0.0.1'
  c.akismet 'ham'
  c.body 'this is a comment'
  c.association :post, :factory => :post 
end