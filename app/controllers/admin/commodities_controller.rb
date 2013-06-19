module Admin
  class CommoditiesController < Controller

    def index
        @commodities = Commodity.includes(:commodity_category).where("commodity_categories.com_type = ?", CommodityCategory::TYPES[0][1]).paginate(paginate_options)
        if (params[:type] == "drugs")
          @commodities = Commodity.includes(:commodity_category).where("commodity_categories.com_type = ?", CommodityCategory::TYPES[0][1]).paginate(paginate_options)
        elsif (params[:type] == "kits")
          @commodities = Commodity.includes(:commodity_category).where("commodity_categories.com_type = ?", CommodityCategory::TYPES[1][1]).paginate(paginate_options)
        else
        # @commodities = Commodity.includes(:commodity_category).paginate(paginate_options)
        end
        @app_title = "Commodities"
    end

    # GET /commodities/1
    # GET /commodities/1.json
    def show
      @commodity = Commodity.find(params[:id])
      @app_title = "Commodity: #{@commodity.name}"
    end

    # GET /commodities/new
    # GET /commodities/new.json
    def new
      if (params[:type] == "drugs")
        @commodity = Commodity.new
      else 
        @commodity = Commodity.new
      end
      @app_title = "New Commodity"
    end

    # GET /commodities/1/edit
    def edit
      @commodity = Commodity.find(params[:id])
      @app_title = "Commodity: #{@commodity.name}"
    end

    # POST /commodities
    # POST /commodities.json
    def create
      @commodity = Commodity.new(params[:commodity])
      @commodity.commodity_type = params[:type]
      if @commodity.save
        redirect_to admin_commodities_path(:type => params[:type]), notice: 'Commodity was successfully created.'
      else
        render action: "new" 
      end
    end

    # PUT /commodities/1
    # PUT /commodities/1.json
    def update
      @commodity = Commodity.find(params[:id])
      @commodity.commodity_type = params[:type]
      if @commodity.update_attributes(params[:commodity])
        redirect_to admin_commodities_path(:type => params[:type]), notice: 'Commodity was successfully updated.' 
      else
        render action: "edit" 
      end
    end

    # DELETE /commodities/1
    # DELETE /commodities/1.json
    def destroy
      begin
        @commodity = Commodity.find(params[:id])
        @commodity.destroy
        redirect_to admin_commodities_url(:type => params[:type]), :notice => "Commodity has been removed" 
      rescue Exception => e
        redirect_to admin_commodities_url, :error => e.message         
      end
      
    end
  end
end