Factory.define(:post) do |p|
  p.title 'Foo'
  p.body 'this is a post'
end

Factory.define(:comment) do |c|
  c.author 'John Doe'
  c.author_url ''
  c.author_email ''
  c.user_ip '127.0.0.1'
  c.body 'this is a comment'
  c.association :post, :factory => :post 
end