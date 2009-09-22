class Admin::HealthController < Admin::BaseController
  verify :method => 'post', :only => 'throw_exception', :render => {:text => 'Method not allowed', :status => 405}, :add_headers => {"Allow" => "POST"}

  def index
  end

  def throw_exception
    raise RuntimeError
  end
end
