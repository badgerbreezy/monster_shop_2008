require 'rails_helper'

RSpec.describe 'Cart creation' do
  describe 'When I visit an items show page' do

    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 50)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      @bulk_discount_1 = BulkDiscount.create!(
        description: "5% on 20+",
        discount_percent: 5,
        minimum_quantity: 20,
        merchant: @mike
      )
      @bulk_discount_2 = BulkDiscount.create!(
        description: "10% on 40+",
        discount_percent: 10,
        minimum_quantity: 40,
        merchant: @mike
      )
    end

    it "I see a link to add this item to my cart" do
      visit "/items/#{@paper.id}"
      expect(page).to have_button("Add To Cart")
    end

    it "I can add this item to my cart" do
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      expect(page).to have_content("#{@paper.name} was successfully added to your cart")
      expect(current_path).to eq("/items")

      within 'nav' do
        expect(page).to have_content("Cart: 1")
      end

      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      within 'nav' do
        expect(page).to have_content("Cart: 2")
      end
    end

    it "When I have items in cart, I can increment/decrement" do
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit "/cart"
      expect(page).to have_content("Cart: 1")

      within ".quantity" do
        expect(page).to have_button("+")
        click_button "+"
      end

      expect(page).to have_content("Cart: 2")

      within ".quantity" do
        50.times do
          click_button "+"
        end
      end

      expect(page).to have_content("Cannot add item")

      within ".quantity" do
        expect(page).to have_button("-")
        click_button "-"
      end

      expect(page).to have_content("Cart: 49")

      within ".quantity" do
        expect(page).to have_button("-")
        50.times do
          click_button "-"
        end
      end

      expect(page).to have_content("Cart: 0")
      expect(page).to have_content("Cannot decrement item below 0")
    end

    it "I am notified of the applied discount appropriately" do
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      visit "/cart"

      within ".quantity" do
        19.times do
          click_button "+"
        end
      end

      expect(page).to have_content("#{@bulk_discount_1.description} for #{@paper.name} applied!")
      expect(page).to_not have_content("#{@bulk_discount_2.description} for #{@paper.name} applied!")

      within ".quantity" do
        20.times do
          click_button "+"
        end
      end

      expect(page).to_not have_content("#{@bulk_discount_1.description} for #{@paper.name} applied!")
      expect(page).to have_content("#{@bulk_discount_2.description} for #{@paper.name} applied!")

      within ".quantity" do
        expect(page).to have_button("-")
        15.times do
          click_button "-"
        end
      end

      expect(page).to_not have_content("#{@bulk_discount_2.description} for #{@paper.name} applied!")
      expect(page).to have_content("#{@bulk_discount_1.description} for #{@paper.name} applied!")

      within ".quantity" do
        expect(page).to have_button("-")
        6.times do
          click_button "-"
        end
      end

      expect(page).to_not have_content("#{@bulk_discount_2.description} for #{@paper.name} applied!")
      expect(page).to_not have_content("#{@bulk_discount_1.description} for #{@paper.name} applied!")
    end
  end
end
