class OrderLine < ActiveRecord::Base
  belongs_to :order
  belongs_to :commodity
  attr_accessible :earliest_expiry, :monthly_use, :quantity_suggested, :quantity_system_calculation, :status, 
                  :stock_on_hand, :user_data_entry_note, :user_reviewer_note,:arv_type, :commodity_id, 
                  :site_suggestion, :test_kit_waste_acceptable, :number_of_client, :consumption_per_client_per_month

  validates :stock_on_hand, :monthly_use, :quantity_system_calculation, :numericality => true, :allow_nil => true                

  default_scope order('monthly_use DESC')

  attr_accessor :site_suggestion, :test_kit_waste_acceptable, :number_of_client, :consumption_per_client_per_month

  validate :quantity_suggested_valid?

  def quantity_suggested_valid?
    arv_type == CommodityCategory::TYPES_DRUG ? quantity_suggested_drug? : quantity_suggested_kit?
  end

  def filter number
     number.to_s + "%"
  end

  def cal_drug
    consumtion        = self.number_of_client.to_i * self.consumption_per_client_per_month.to_i
    system_suggestion = consumtion - self.stock_on_hand.to_i
    diff = self.quantity_suggested - system_suggestion 
    max  = self.quantity_suggested >= system_suggestion ?  self.quantity_suggested : system_suggestion
    100 * diff.abs / max
  end

  def cal_kit
    consumtion = self.number_of_client.to_i * self.consumption_per_client_per_month.to_i
    system_suggestion = consumtion - self.stock_on_hand.to_i
    100 * (self.monthly_use - system_suggestion) / self.monthly_use
  end

  def quantity_suggested_drug?
    return true  if ( stock_on_hand.blank?  || quantity_suggested.blank?)
    cal = cal_drug
    if cal > self.site_suggestion
        message = "Quantity Suggested is not acceptable system calculation = " + filter(cal) + " must be less than or equal to site suggestion = " + filter(self.site_suggestion)
        errors.add(:commodity, message)   
        return false     
    end
    return true
  end

  def quantity_suggested_kit?
    return true if(self.stock_on_hand.blank?  || self.monthly_use.blank?)     
    cal = cal_kit
    if(cal > self.test_kit_waste_acceptable.to_f)
      message =  "Quantity Suggested is not acceptable system calculation = " + filter(cal) + " must be less than or equal to site wastage = " + filter(self.test_kit_waste_acceptable) 
      errors.add(:commodity, message) 
      return false
    end
    return true
  end

  def calculate_suggested_order
     value = (self.quantity_system_calculation - self.quantity_suggested).abs
     max = self.quantity_system_calculation > self.quantity_suggested ? self.quantity_system_calculation : self.quantity_suggested
     (100*value)/max
  end              

  def calculate_quantity_system_suggestion temp_order
    surv_sites = temp_order.surv_sites

    return nil if surv_sites[self.arv_type].nil?
    surv_site = surv_sites[self.arv_type]

    surv_site.surv_site_commodities.each do |surv_site_commodity|
      if surv_site_commodity.commodity == self.commodity

          self.site_suggestion                  = temp_order.site.suggestion_order
          self.test_kit_waste_acceptable        = temp_order.site.test_kit_waste_acceptable
          self.number_of_client                 = surv_site_commodity.quantity.to_i

          total                                 =  self.consumption_per_client_per_month * self.number_of_client
          system_suggestion                     = total - self.stock_on_hand.to_i
          self.quantity_system_calculation      = system_suggestion
          
          break
      end
    end
  end

  class << self
  	def drug
  		where ['arv_type = :type ', :type => CommodityCategory::TYPES_DRUG ]
  	end

  	def kit
  		where [ 'arv_type = :type ', :type => CommodityCategory::TYPES_KIT ]
  	end
  end	


end
