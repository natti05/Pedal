class BicyclesController < ApplicationController
  # before_action :find_bicycle, only: %i(show)
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    if params[:query].present?
      @bicycles = Bicycle.search_by_address(params[:query])
    else
      @bicycles = Bicycle.all
    end
      @query = params[:query]
      @bicycles = Bicycle.geocoded #returns bicycles with coordinates

      @markers = @bicycles.map do |bicycle|
        {
          lat: bicycle.latitude,
          lng: bicycle.longitude,
          infoWindow: render_to_string(partial: "infowindow", locals: { bicycle: bicycle }),
          image_url: helpers.asset_url('bikelogo.png')
        }
    end
  end

  def show
    @bicycle = Bicycle.find(params[:id])
    @booking = Booking.new
  end

  def new
    @bicycle = Bicycle.new
  end

  def create
    @bicycle = Bicycle.new(bicycle_params)
    @bicycle.user = current_user
    if @bicycle.save
      redirect_to bicycle_path(@bicycle)
    else
      render :new
    end
  end
  private
  def bicycle_params
    params.require(:bicycle).permit(:name, :day_price, :address, :description, :category, photos: [])
  end
  def find_bicycle
    @bicycle = Bicycle.find(params[:id])
  end

end
