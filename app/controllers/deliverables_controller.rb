class DeliverablesController < ApplicationController
  # GET /deliverables
  # GET /deliverables.xml

  layout 'cmu_sv'
  before_filter :authenticate_user, :except => [:index, :list]

  
  def index
    @deliverables = Deliverable.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deliverables }
    end
  end

  # GET /deliverables/1
  # GET /deliverables/1.xml
  def show

    @deliverable = Deliverable.find(params[:id])
    if (check_permissions(@deliverable))
     flash[:error] = "You don't have permission to do this action."
     redirect_to(deliverables_url) and return
    end

    @deliverable_versions = @deliverable.versions.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deliverable }
    end
  end

  # GET /deliverables/new
  # GET /deliverables/new.xml
  def new
    @deliverable = Deliverable.new
    @deliverable.uploader = Person.find(current_user.id)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @deliverable }
    end
  end

  # GET /deliverables/1/edit
  def edit
    @deliverable = Deliverable.find(params[:id])
    if (check_permissions(@deliverable))
       flash[:error] = "You don't have permission to do this action."
       redirect_to(deliverables_url) and return
    end

  end

  # POST /deliverables
  # POST /deliverables.xml
  def create
    @deliverable = Deliverable.new(params[:deliverable])
    @deliverable.uploader_id = current_user.id

    respond_to do |format|
      if @deliverable.save
         GenericMailer.deliver_email(
             :to => @deliverable.team.primary_faculty.email,
             :subject => "#{@deliverable.team.name} has submitted a deliverable",
             :message => "#{@deliverable.name} has just been submitted.",
             :url_label => "",
             :url => "", # + edit_peer_evaluation_path(team))
  #           :from => from_address,
             :cc => @deliverable.team.email
            )
         
      #  GenericMailer.deliver_email(:subject => "Deliverable submitted", :to => "gaurav.sinha@sv.cmu.edu", :cc => "phil.melzer@sv.cmu.edu", :message => "  Hi  ")
        flash[:notice] = 'Deliverable was successfully created.'
        format.html { redirect_to(@deliverable) }
        format.xml  { render :xml => @deliverable, :status => :created, :location => @deliverable }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deliverable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deliverables/1
  # PUT /deliverables/1.xml
  def update
    @deliverable = Deliverable.find(params[:id])

    respond_to do |format|
      if @deliverable.update_attributes(params[:deliverable])
        flash[:notice] = 'Deliverable was successfully updated.'
        format.html { redirect_to(@deliverable) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @deliverable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deliverables/1
  # DELETE /deliverables/1.xml
  def destroy
    @deliverable = Deliverable.find(params[:id])

    if (check_permissions(@deliverable))
       flash[:error] = "You don't have permission to do this action."
       redirect_to(deliverables_url) and return
    end

    @deliverable.destroy

    respond_to do |format|
      format.html { redirect_to(deliverables_url) }
      format.xml  { head :ok }
    end
  end

def restore
  puts "testing restore"
  puts current_user.id
   @deliverable = Deliverable.find(params[:deliverable_id])
   @deliverable.revert_to! params[:version_id]
   redirect_to :action => 'show', :id => @deliverable
end

private
  def authenticate_user
    if current_user == nil
     flash[:error] = "You don't have permission to do this action."
      redirect_to(deliverables_url) and return 
    end
  end

def check_permissions (deliverable)
    is_member = false

    deliverable.team.people.each do |member|
      if current_user.id == member.id
        is_member = true
        break
      end
    end
    
     return !(current_user.is_admin? || current_user.is_staff? || deliverable.uploader_id == current_user.id || (is_member && !deliverable.is_individual))
   end
end
