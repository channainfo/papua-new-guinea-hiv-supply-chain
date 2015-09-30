# == Schema Information
#
# Table name: commodities
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  commodity_category_id       :integer
#  consumption_per_client_pack :integer
#  consumption_per_client_unit :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  abbreviation                :string(255)
#  quantity_per_packg          :string(255)
#  pack_size                   :float
#  regimen_id                  :integer
#  lab_test_id                 :integer
#  unit_id                     :integer
#  strength_dosage             :string(255)
#

class Commodity < ActiveRecord::Base

  attr_accessor :commodity_type

  attr_accessible :commodity_category_id, :commodity_category, :pack_size, :name, :abbreviation, :unit_id,
                  :strength_dosage, :quantity_per_packg, :commodity_type, :lab_test_id, :regimen_id

  belongs_to :commodity_category
  belongs_to :unit

  belongs_to :regimen
  belongs_to :lab_test

  has_many :order_lines

  validates :name, :unit_id, :commodity_category_id, presence: true
  validates :name, uniqueness: true

  validates :strength_dosage, :abbreviation, :quantity_per_packg, :regimen_id, presence: true, if: ->(u) { self.commodity_type == CommodityCategory::TYPES_DRUG }
  validates :pack_size, :lab_test_id, presence: true, if: ->(u) { u.commodity_type == CommodityCategory::TYPES_KIT }
  validates :pack_size, numericality: { greater_than: 0 } , if: ->(u) { u.commodity_type == CommodityCategory::TYPES_KIT }

  # validate :validate_commodity_type
  # def validate_commodity_type
  #   if (self.commodity_type == CommodityCategory::TYPES_DRUG )
  #     errors.add(:abbreviation, "can't be blank") if self.abbreviation.blank?
  #     errors.add(:quantity_per_packg, "can't be blank") if self.quantity_per_packg.blank?
  #     errors.add(:regimen_id, "can't be blank") if self.regimen_id.blank?
  #   else
  #     errors.add(:pack_size, "can't be blank") if self.pack_size.blank?
  #     errors.add(:lab_test_id, "can't be blank") if self.lab_test_id.blank?
  #   end
  # end

  def self.of_kit
    from_type CommodityCategory::TYPES_KIT
  end

  def self.of_drug
    from_type CommodityCategory::TYPES_DRUG
  end

  def self.from_type type
    Commodity.includes(:commodity_category)
             .where("commodity_categories.com_type = ?", type)
             .order("commodity_categories.name ASC")
  end  
end
