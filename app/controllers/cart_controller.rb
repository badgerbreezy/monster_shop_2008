class CartController < ApplicationController
  def add_item
    item = Item.find(params[:item_id])
    item_id = item.id
    cart.add_item(item_id.to_s)
    flash[:success] = "#{item.name} was successfully added to your cart"
    redirect_to "/items"
  end

  def show
    @items = cart.items
    if current_admin_user?
      render file: "/public/404"
    end
  end

  def empty
    session.delete(:cart)
    redirect_to '/cart'
  end

  def remove_item
    session[:cart].delete(params[:item_id])
    redirect_to '/cart'
  end

  def increment
    item = Item.find(params[:item_id])
    quantity = cart.quantity(item)
    discount = BulkDiscount.apply_discount(quantity)
    if discount
      flash[:notice] = "#{discount.description} for #{item.name} applied!"
    end
    if cart.items[item] < item.inventory
      cart.add_item(item.id.to_s)
    else
      flash[:error] = "Cannot add item"
    end
    redirect_to '/cart'
  end

  def decrement
    item = Item.find(params[:item_id])
    quantity = cart.quantity(item)
    discount = BulkDiscount.apply_discount(quantity)
    if discount
      flash[:notice] = "#{discount.description} for #{item.name} applied!"
    end
    if cart.items[item] > 0
      cart.decrement_item(item)
    else
      flash[:error] = "Cannot decrement item below 0"
    end
    redirect_to '/cart'
  end
end
