class CreateShipmentLinesTable < ActiveRecord::Migration
  def change
  	create_table :shipment_lines do |t|
  		t.references :shipment
  		t.integer :quantity_suggested
  		t.integer :quantity_issued
  		t.integer :quantity_received
  		t.timestamps
  	end
  end
end
