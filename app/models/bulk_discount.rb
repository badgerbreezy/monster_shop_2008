class BulkDiscount < ApplicationRecord
  validates_presence_of :description
  validates_inclusion_of :discount_percent, in: 1..100, message: "must be within 1 and 100 percent"
  validates :minimum_quantity, numericality: { greater_than: 0 }

  belongs_to :merchant

  def calculate_discount(total)
    total * ((100 - discount_percent) * 0.01)
  end

  def self.apply_discount(quantity)
    order(:minimum_quantity).where("minimum_quantity <= ?", quantity).last
  end
end
