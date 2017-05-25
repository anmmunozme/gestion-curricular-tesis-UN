class CreateRemindersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_create_reminder, only: [:show, :edit, :update, :destroy]

  # GET /create_reminders
  # GET /create_reminders.json
  def index
    @create_reminders = CreateReminder.all
    @gradeworks = Gradework.all
    @mail_templates = MailTemplate.all
    @juriese = User.users_email_jury
    @directorse = User.users_email_director
    @studentse = User.users_email_student
  end

  # GET /create_reminders/1
  # GET /create_reminders/1.json
  def show
  end

  # GET /create_reminders/new
  def new7
    @create_reminder = CreateReminder.new
    @gradeworks = Gradework.all
    @mail_templates = MailTemplate.all
    @juriese = User.users_email_jury
    @directorse = User.users_email_director
    @studentse = User.users_email_student
  end

  # GET /create_reminders/1/edit
  def edit
    @gradeworks = Gradework.all
    @mail_templates = MailTemplate.all
    @juriese = User.users_email_jury
    @directorse = User.users_email_director
    @studentse = User.users_email_student

    @grad_tesis = @gradework.joins(:name).ids
    @templates_name = @gradework.joins(:name).ids

    @grad_email_directors = @gradework.users.joins(:roles).where(roles: {name: "Director"}).emails
    @grad_email_juries = @gradework.users.joins(:roles).where(roles: {name: "Jury"}).emails
    @grad_email_students = @gradework.users.joins(:roles).where(roles: {name: "Student"}).emails
  end

  # POST /create_reminders
  # POST /create_reminders.json
  def create
    @create_reminder = CreateReminder.new(create_reminder_params)
    if params.has_key?(:student) and params[:student] != [""]
    student = params[:student]
    if (student == "on")
      @create_reminder.student = true
    else
      @create_reminder.student = false
    end
    #@create_reminder.users << User.find(students)
    end

    if params.has_key?(:jury) and params[:jury] != [""]
    jury = params[:jury]
    if (jury == "on")
      @create_reminder.jury = true
    else
      @create_reminder.jury = false
    end
    end

    if params.has_key?(:director) and params[:director] =! ""
    director = params[:director]
    if (director == "on")
      @create_reminder.director = true
    else
      @create_reminder.director = false
    end
      #@create_reminder.users << User.find(directors)
    end

    if params.has_key?(:gradework) and params[:gradework] != [""]
      gradework = params[:gradework]
      @create_reminder.gradework = Gradework.find(gradework)
    end

    if params.has_key?(:mail_template) and params[:mail_template] != [""]
      mail = params[:mail_template]
      @create_reminder.mail_template = MailTemplate.find(mail)
    end

    @create_reminder.date = params[:date]

    respond_to do |format|
      # MTemplateMailer.useTemplate(@juriese,  @templates_name).deliver_now
      if @create_reminder.save

        format.html { redirect_to @create_reminder, notice: 'Create reminder was successfully created.' }
        format.json { render :show, status: :created, location: @create_reminder }
      else
        format.html { render :new }
        format.json { render json: @create_reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /create_reminders/1
  # PATCH/PUT /create_reminders/1.json
  def update
    respond_to do |format|
      if @create_reminder.update(create_reminder_params)
        format.html { redirect_to @create_reminder, notice: 'Create reminder was successfully updated.' }
        format.json { render :show, status: :ok, location: @create_reminder }
      else
        format.html { render :edit }
        format.json { render json: @create_reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /create_reminders/1
  # DELETE /create_reminders/1.json
  def destroy
    @create_reminder.destroy
    respond_to do |format|
      format.html { redirect_to create_reminders_url, notice: 'Create reminder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_create_reminder
      @create_reminder = CreateReminder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def create_reminder_params
      params.require(:create_reminder).permit(:state, :date, :time, :datetime, :gradework, :mail_template)
    end
end
