class Admin::PagesController < Admin::BaseController
  include PageAdminHelper
  before_filter :login_required
  before_filter :load_new_page, :only => [:new, :create]
  before_filter :load_page, :only => [:edit, :update, :destroy, :shift_order]

  protected
  def load_page
    @page = Page.find params[:id] 
  end

  def load_new_page
    @page = Page.new(params[:page])
  end

  public
	def index
    @page_hierarchy = Page.all
    respond_to do |format|
      format.html # index.rhtml
    end
  end
	
  def edit
  end 

  def update
    if @page.update_attributes(params[:page])
      flash.now[:message] = 'Page Updated Successfully'
      @preview_url = @page.ancestor_path + @page.name
      @page_id = @page.id
      render :action => 'preview'
    else
      render :action => 'edit'
    end
  end

  def new
    @page.linked, @page.published = true, true
    @page.parent_id = params[:parent_id] if params[:parent_id]
    @page.page_order = params[:page_order] if params[:page_order]
  end 
 
  def create
    @page.name = @page.name.gsub(' ', '_')
    if @page.save
      message = 'Page Added Successfully'
      @preview_url = @page.ancestor_path + @page.name
      @page_id = @page.id
      respond_to do |format|
        format.html{ 
          flash[:notice] = message
          redirect_to admin_pages_path
        }
        format.js{
          flash.now[:message] = message
          render 'preview', "<h1>Page Added Successfully</h1>"
        }
      end
    else
      render :action => 'new'
    end
  end

 def destroy
   params[:parent_id] = @page.parent_id # Capture parent before destroying
   @page.children.each do |sub|
     sub.parent_id = 0
     sub.save
   end
   page_name = @page.name
   @page.destroy
   respond_to do |format|
     format.html{
       flash[:notice] = "Page: #{page_name} was deleted"
       redirect_to admin_pages_path
     }
     format.js{ manage_tree }
   end
 end

 def menu
   # @admin = admin?
   if params[:id]
     render :partial => "menu/" + params[:id]
   else
     render :partial => "menu/main"
   end
 end

  # Most of this code should go into Page model instead.
  def shift_order
    @page.swap! params[:shift].to_i if @page and params[:shift]
    params[:parent_id] = @page.parent_id
    respond_to do |format|
      format.html{ redirect_to admin_pages_path }
      format.js{ manage_tree }
    end
  end
 
  def manage_tree
    # Load entire tree with children.each
    render(:partial => 'manage_tree', :object => Page.root, :locals => { :initialize => true}) and return unless params[:parent_id]
    # Not DRY and will require refactoring later
    page = Page.find(params[:parent_id])
    if (page == Page.root) 
      render_tree(page, :is_first => true, :is_last => true, :can_delete => false, :initialize => false)
    else 
      sibs = page.self_and_siblings
      render_tree(page,
        :is_first => (page == sibs.first),
        :is_last => (page == sibs.last),
        :can_delete => true,
        :initialize => false )
    end
  end
end
