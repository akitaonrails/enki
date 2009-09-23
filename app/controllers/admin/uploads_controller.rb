class Admin::UploadsController < Admin::BaseController
  def index
    @upload = Upload.new
    @uploads = Upload.paginate(
      :order => "created_at DESC",
      :page => params[:page])
  end
  
  def show
    @upload = Upload.find(params[:id])
  end
  
  def create
    @upload = Upload.new(params[:upload])
    if @upload.save
      flash[:notice] = "Successfully created upload."
    end
    redirect_to admin_uploads_url
  end
  
  def destroy
    @upload = Upload.find(params[:id])
    @upload.destroy
    flash[:notice] = "Successfully destroyed upload."
    redirect_to admin_uploads_url
  end
end
