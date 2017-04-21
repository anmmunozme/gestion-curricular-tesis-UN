class GradeworksController < ApplicationController
  before_action :set_gradework, only: [:show, :edit, :update, :destroy]

  # GET /gradeworks
  # GET /gradeworks.json
  def index
    @gradeworks = Gradework.all
    @juries = User.users_jury
    @directors = User.users_director
    @students = User.users_student
  end

  # GET /gradeworks/1
  # GET /gradeworks/1.json
  def show
  end

  # GET /gradeworks/new
  def new
    @gradework = Gradework.new
    @juries = User.users_jury
    @directors = User.users_director
    @students = User.users_student
  end

  # GET /gradeworks/1/edit
  def edit

    @juries = User.users_jury
    @directors = User.users_director
    @students = User.users_student

    @grad_directors = @gradework.users.joins(:roles).where(roles: {name: "Director"}).ids
    @grad_juries = @gradework.users.joins(:roles).where(roles: {name: "Jury"}).ids
    @grad_students = @gradework.users.joins(:roles).where(roles: {name: "Student"}).ids
  end

  # POST /gradeworks
  # POST /gradeworks.json
  def create
    @gradework = Gradework.new(gradework_params)

    if params.has_key?(:students) and params[:students] != [""]
    students = params[:students]
    @gradework.users << User.find(students)
    end

    if params.has_key?(:juries) and params[:juries] != [""]
    juries = params[:juries]
    @gradework.users << User.find(juries)
    end

    if params.has_key?(:directors) and params[:directors] =! ""
    directors = params[:directors]
    @gradework.users << User.find(directors)
    end
	
	files_list = ActiveSupport::JSON.decode(params[:files_list])	
    # product=Product.create(name: params[:name], description: params[:description])
    Dir.mkdir("#{Rails.root}/public/uploads/gradework/file/"+gradework.id.to_s)
    files_list.each do |pic|
      File.rename( "#{Rails.root}/"+pic, "#{Rails.root}/public/uploads/gradework/file/"+gradework.id.to_s+'/'+File.basename(pic))
      gradework.pics.create(name: pic)
	end

    respond_to do |format|
      if @gradework.save!
        format.html { redirect_to @gradework, notice: 'La tesis se creó correctamente' }
        format.json { render :show, status: :created, location: @gradework }
      else
        format.html { redirect_to @gradework, notice: 'La tesis no se pudo crear correctamente' }
        format.json { render json: @gradework.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gradeworks/1
  # PATCH/PUT /gradeworks/1.json
  def update

    @gradework.users = []

    if params.has_key?(:students) and params[:students] != [""]
      students = params[:students]
      @gradework.users << User.find(students)
    end

    if params.has_key?(:juries) and params[:juries] != [""]
      juries = params[:juries]
      @gradework.users << User.find(juries)
    end

    if params.has_key?(:directors) and params[:directors] =! ""
      directors = params[:directors]
      @gradework.users << User.find(directors)
    end

    respond_to do |format|
      if @gradework.update(gradework_params)
        format.html { redirect_to @gradework, notice: 'La tesis se modificó correctamente' }
        format.json { render :show, status: :ok, location: @gradework }
      else
        format.html { redirect_to @gradework, notice: 'La tesis no se modificó correctamente' }
        #format.html { render :edit }
        format.json { render json: @gradework.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gradeworks/1
  # DELETE /gradeworks/1.json
  def destroy
    @gradework.destroy
    respond_to do |format|
      format.html { redirect_to gradeworks_url, notice: 'La tesis se eliminó correctamente' }
      format.json { head :no_content }
    end
  end
  
	
  def createFile
    files_list = ActiveSupport::JSON.decode(params[:files_list])	
    # product=Product.create(name: params[:name], description: params[:description])
    Dir.mkdir("#{Rails.root}/public/uploads/gradework/file/"+gradework.id.to_s)
    files_list.each do |pic|
      File.rename( "#{Rails.root}/"+pic, "#{Rails.root}/public/uploads/gradework/file/"+gradework.id.to_s+'/'+File.basename(pic))
      gradework.pics.create(name: pic)
    end
    # redirect_to product_new_url, notice: "Success! Product is created."
  end

  def upload_old
    uploaded_pics = params[:file] # Take the files which are sent by HTTP POST request.
    time_footprint = Time.now.to_i.to_formatted_s(:number) # Generate a unique number to rename the files to prevent duplication

    uploaded_pics.each do |pic|
      # these two following comments are some useful methods to debug
      # abort pic.class.inspect -> It is similar to var_dump($variable) in PHP.
      # abort pic.is_a?(Array).inspect -> With "is_a?" method, you can find the type of variable
      # abort pic[1].original_filename.inspect
      # The following snippet saves the uploaded content in '#{Rails.root}/public/uploads' with a name which contains a time footprint + the original file
      # reference: http://guides.rubyonrails.org/form_helpers.html
      File.open(Rails.root.join('public', 'uploads', pic[1].original_filename), 'wb') do |file|
        file.write(pic[1].read)
        File.rename(file, 'public/uploads/' + time_footprint + pic[1].original_filename)
      end
    end
    files_list = Dir['public/uploads/*'].to_json #get a list of all files in the {public/uploads} directory and make a JSON to pass to the server
    render json: { message: 'You have successfully uploded your images.', files_list: files_list } #return a JSON object amd success message if uploading is successful
  end

  def upload
    uploaded_pics = params[:file]
    time_footprint = Time.now.to_i.to_formatted_s(:number)
	#abort uploaded_pics.inspect
    uploaded_pics.each do |index,pic|
      File.open(Rails.root.join('public', 'uploads', pic.original_filename), 'wb') do |file|
        file.write(pic.read)
        File.rename(file, 'public/uploads/' + time_footprint + pic.original_filename)
      end
    end
    files_list = Dir['public/uploads/*'].to_json
    render json: { message: 'You have successfully uploded your images.', files_list: files_list }
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gradework
      @gradework = Gradework.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gradework_params
      params.require(:gradework).permit(:name, :description, :status, :delivery_date, :begin_date, :hour, :locale, :semester, :file)
    end
end
