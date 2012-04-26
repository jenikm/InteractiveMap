class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  def tracking_map
    #THIS WILL BE REPLACED WITH customer.orders.map(&:order_items).flatten with filters when integrated
    #@order_items = OrderItem.find(:all, :limit => 1, :conditions => "shipments.id IS NOT NULL", :order => "order_items.id desc", :include => :shipments)
    @order_items = OrderItem.find(:all, :limit => 20, :conditions => "status in (1,2,3,4,5)", :order => "order_items.id desc", :include => :shipments)
    
    ActiveRecord::Base.transaction do
      @order_items.each do | item |
        if item.geocode_seller
          item.save!
        end
      end
    end
    @shipments = @order_items.map(&:shipments).flatten
    Shipment.transaction do
      @shipments.each do |shipment|
        #TODO add check to prevent checking more often than 5 min interval
        shipment.build_shipment_tracking_logs
        shipment.save!
      end
    end

    @shipments = @shipments.map do |shipment|
      shipment.attributes.merge({:order_items => shipment.order_items.map(&:attributes), :shipment_tracking_logs => shipment.shipment_tracking_logs.map{|stl| stl.geo_location ? stl.attributes.merge(stl.geo_location.attributes) : stl.attributes}})
    end

    @order_item_infos = @order_items.map{|oi| {:order_item => oi, :geo_locations => oi.get_geolocation_path}}
    @br_office_infos = {:geo_location => OrderItem.br_office_geolocation, :order_items => @order_items.select{|oi| oi.status == 3}}
    @status_names = OrderItem::VALID_STATUSES.map{|s| OrderItem.status_name(s)}.unshift("Not Purchased from seller")
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to(@account) }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to(@account) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
end
