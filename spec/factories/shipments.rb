# == Schema Information
#
# Table name: shipments
#
#  id                   :integer          not null, primary key
#  consignment_number   :string(20)
#  status               :string(25)
#  shipment_date        :date
#  received_date        :datetime
#  user_id              :integer
#  site_id              :integer
#  order_id             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sms_logs_count       :integer          default(0)
#  shipment_lines_count :integer          default(0)
#  last_notified_date   :datetime
#  lost_date            :datetime         default(2015-11-16 04:07:55 UTC)
#  cost                 :float
#  carton               :integer
#  site_messages_count  :integer          default(0)
#  weight               :float
#

FactoryGirl.define do
  factory :shipment do
    shipment_date '2013-06-25 11:31:27'
    status Shipment::STATUS_IN_PROGRESS
    cost 100.25
    carton 10
    order
    user
    site
    weight 1.0
    sequence(:consignment_number) {|n| (100000000 + n).to_s }
  end
end
