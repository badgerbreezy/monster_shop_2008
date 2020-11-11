class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @bulk_discounts = BulkDiscount.all
  end

  def new
    @bulk_discount = BulkDiscount.new(discount_params)
  end

  def create
    @merchant = current_user.merchant
    @bulk_discount = @merchant.bulk_discounts.new(discount_params)
    if @bulk_discount.valid?
      @bulk_discount.save!
      flash[:notice] = "Discount Created!"
      redirect_to '/merchant/bulk_discounts'
    else
      flash[:error] = @bulk_discount.errors.full_messages.to_sentence
      redirect_to '/merchant/bulk_discounts/new'
    end
  end

  def edit
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    @merchant = current_user.merchant
    @bulk_discount = @merchant.bulk_discounts.find(params[:id])
    if @bulk_discount.valid?
      @bulk_discount.update(discount_params)
      flash[:notice] = "Discount Updated!"
      redirect_to '/merchant/bulk_discounts'
    else
      flash[:error] = @bulk_discount.errors.full_messages.to_sentence
      redirect_to "/merchant/bulk_discounts/#{@bulk_discount.id}/edit"
    end
  end

  def destroy
    bulk_discount = BulkDiscount.find(params[:id])
    bulk_discount.destroy!
    redirect_to '/merchant/bulk_discounts'
  end

  private
  def discount_params
    params.permit(:description, :discount_percent, :minimum_quantity)
  end
end
