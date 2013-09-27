class PoolsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]
  before_filter :janitor_only, :only => [:destroy]

  def new
    @pool = Pool.new
    respond_with(@pool)
  end

  def edit
    @pool = Pool.find(params[:id])
    respond_with(@pool)
  end

  def index
    @pools = Pool.undeleted.search(params[:search]).order("updated_at desc").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@pools) do |format|
      format.xml do
        render :xml => @pools.to_xml(:root => "pools")
      end
    end
  end

  def search
  end

  def show
    @pool = Pool.find(params[:id])
    @post_set = PostSets::Pool.new(@pool, params[:page])
    respond_with(@pool)
  end

  def create
    @pool = Pool.create(params[:pool])
    flash[:notice] = "Pool created"
    respond_with(@pool)
  end

  def update
    # need to do this in order for synchronize! to work correctly
    @pool = Pool.find(params[:id])
    @pool.attributes = params[:pool]
    @pool.synchronize!
    @pool.save
    flash[:notice] = "Pool updated"
    respond_with(@pool)
  end

  def destroy
    @pool = Pool.find(params[:id])
    if !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @pool.update_attribute(:is_deleted, true)
    @pool.create_mod_action_for_delete
    flash[:notice] = "Pool deleted"
    respond_with(@pool)
  end

  def undelete
    @pool = Pool.find(params[:id])
    if !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @pool.update_attribute(:is_deleted, false)
    @pool.create_mod_action_for_undelete
    flash[:notice] = "Pool undeleted"
    respond_with(@pool)
  end

  def revert
    @pool = Pool.find(params[:id])
    @version = PoolVersion.find(params[:version_id])
    @pool.revert_to!(@version)
    flash[:notice] = "Pool reverted"
    respond_with(@pool) do |format|
      format.js
    end
  end
end
