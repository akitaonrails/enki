require File.dirname(__FILE__) + '/../../spec_helper'
 
describe Admin::UploadsController do
  fixtures :all
  integrate_views
  
  describe "with at least one upload already recorded" do
    before(:each) do
      session[:logged_in] = true
      @upload = Upload.create(:avatar => fixture_file_upload('rails.png'))
    end
  
    it "index action should render index template" do
      get :index
      response.should render_template(:index)
    end
  
    it "show action should render show template" do
      get :show, :id => @upload.id
      response.should render_template(:show)
    end
    
    it "destroy action should destroy model and redirect to index action" do
      lambda {
        delete :destroy, :id => @upload.to_param
      }.should change{ Upload.count }.by(-1)
      response.should redirect_to(admin_uploads_url)
    end
  end

  describe "with an empty uploads table" do
    before(:each) do
      session[:logged_in] = true
    end
  
    it "create action should return to uploads list when model is valid" do
      lambda {
        post :create, :upload => { :avatar => fixture_file_upload('rails.png') }
      }.should change{ Upload.count }.by(1)
      response.should redirect_to(admin_uploads_url)
    end  
  end
end
