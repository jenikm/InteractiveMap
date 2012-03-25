class OrderItemTrackingNumbersController < ApplicationController
  # GET /order_item_tracking_numbers
  # GET /order_item_tracking_numbers.xml
  def index
    @order_item_tracking_numbers = OrderItemTrackingNumber.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @order_item_tracking_numbers }
    end
  end

  # GET /order_item_tracking_numbers/1
  # GET /order_item_tracking_numbers/1.xml
  def show
    @order_item_tracking_number = OrderItemTrackingNumber.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order_item_tracking_number }
    end
  end

  # GET /order_item_tracking_numbers/new
  # GET /order_item_tracking_numbers/new.xml
  def new
    @order_item_tracking_number = OrderItemTrackingNumber.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order_item_tracking_number }
    end
  end

  # GET /order_item_tracking_numbers/1/edit
  def edit
    @order_item_tracking_number = OrderItemTrackingNumber.find(params[:id])
  end

  # POST /order_item_tracking_numbers
  # POST /order_item_tracking_numbers.xml
  def create
    @order_item_tracking_number = OrderItemTrackingNumber.new(params[:order_item_tracking_number])

    respond_to do |format|
      if @order_item_tracking_number.save
        flash[:notice] = 'OrderItemTrackingNumber was successfully created.'
        format.html { redirect_to(@order_item_tracking_number) }
        format.xml  { render :xml => @order_item_tracking_number, :status => :created, :location => @order_item_tracking_number }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order_item_tracking_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /order_item_tracking_numbers/1
  # PUT /order_item_tracking_numbers/1.xml
  def update
    @order_item_tracking_number = OrderItemTrackingNumber.find(params[:id])

    respond_to do |format|
      if @order_item_tracking_number.update_attributes(params[:order_item_tracking_number])
        flash[:notice] = 'OrderItemTrackingNumber was successfully updated.'
        format.html { redirect_to(@order_item_tracking_number) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order_item_tracking_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /order_item_tracking_numbers/1
  # DELETE /order_item_tracking_numbers/1.xml
  def destroy
    @order_item_tracking_number = OrderItemTrackingNumber.find(params[:id])
    @order_item_tracking_number.destroy

    respond_to do |format|
      format.html { redirect_to(order_item_tracking_numbers_url) }
      format.xml  { head :ok }
    end
  end
end
