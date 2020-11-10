class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @bulk_discounts = BulkDiscount.all
  end

  def new
    @bulk_discount = BulkDiscount.new(discount_params)
  end

  def create
    @bulk_discount = BulkDiscount.new(discount_params)
    @bulk_discount.merchant = current_user.merchant
    if @bulk_discount.save
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
    @bulk_discount = BulkDiscount.find(params[:id])
    @bulk_discount.update(discount_params)
    redirect_to '/merchant/bulk_discounts'
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
