class ShipmentLine < ActiveRecord::Base
	belongs_to :shipment
	belongs_to :order_line
	validates :quantity_suggested, :quantity_issued, :presence => true
	attr_accessible :quantity_issued, :quantity_suggested, :order_line_id, :remark
end