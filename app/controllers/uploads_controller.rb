class UploadsController < ApplicationController
  before_filter :authenticate_user!
  
  def new
  end

  def create
    # Make an object in your bucket for your upload
    obj = S3_BUCKET.objects[File.join(current_user.folder, params[:file].original_filename)]
     # Upload the file
    obj.write(
       file: params[:file],    
       #acl: :public_read
    )

    # Create an object for the upload
    @upload = Upload.new(
      url: obj.public_url,
      name: obj.key,
      userId: current_user.id
    )

    # Save the upload
    if @upload.save
      #redirect_to uploads_path, success: 'File successfully uploaded'
      redirect_to uploads_path, :notice => "Your file was successfully uploaded to ShareBox"
    else
      redirect_to uploads_path, :error => "Your file couldn't be uploaded to ShareBox"
      #flash.now[:notice] = 'There was an error'
      #render :new
    end
  end

  def destroy
    if (params[:id])
      @upload = Upload.find(params[:id])
    
      @upload.destroy
      obj = S3_BUCKET.objects[@upload.name]
      obj.delete
      redirect_to uploads_path, :notice => @upload.name + " was deleted"
    
    else  
        redirect_to uploads_path, :error => "Could not delete " +  @upload.name
    end  
    #redirect_to uploads_path
  end

  def index
    if current_user.folder.nil?
            current_user.folder = generate_random_user_folder_name
            current_user.save
    end
    #@uploads = Upload.all
    @uploads = Upload.where("userId = ?", current_user.id)
  end
  def generate_random_user_folder_name()
        letters = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    return (0...8).map{ letters[rand(letters.length)] }.join
    end
end
