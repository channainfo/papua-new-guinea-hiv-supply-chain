class SmsLog < ActiveRecord::Base
	belongs_to :shipment , :counter_cache => true
	belongs_to :site
	attr_accessible :message, :site, :shipment, :to, :guid, :sms_log, :status, :sms_type

	SMS_TYPE_SHIPMENT = 'Shipment'
	SMS_TYPE_REQUISITION = 'Requisition'
	SMS_TYPE_ASK_CONFIRM  = 'Ask for confirmation'
	
	SMS_TYPES = [SMS_TYPE_SHIPMENT, SMS_TYPE_REQUISITION, SMS_TYPE_ASK_CONFIRM]

	def self.shipment
		where(['sms_type = :sms_type', :sms_type => SmsLog::SMS_TYPE_SHIPMENT ])
	end

	def self.requisition
		where(['sms_type= :sms_type', :sms_type => SmsLog::SMS_TYPE_REQUISITION])
	end

	def self.of_type type
	  return self.requisition if(type == SmsLog::SMS_TYPE_REQUISITION)
	  return self.shipment  
	end
end