# == Schema Information
#
# Table name: sites
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  service_type                 :string(255)
#  suggestion_order             :float
#  order_frequency              :float
#  number_of_deadline_sumission :integer
#  order_start_at               :date
#  test_kit_waste_acceptable    :float
#  address                      :text
#  contact_name                 :string(255)
#  mobile                       :string(255)
#  land_line_number             :string(255)
#  email                        :string(255)
#  province_id                  :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  in_every                     :integer
#  duration_type                :string(255)
#  sms_alerted                  :integer          default(0)
#  site_messages_count          :integer          default(0)
#  town                         :string(255)
#  region                       :string(255)
#  max_alert_deadline           :integer          default(3)
#

class Site < ActiveRecord::Base
  # has_date_format :order_start_at

  has_many :users
  has_many :requisition_reports
  has_many :orders
  has_many :surv_sites
  has_many :sms_logs
  has_many :shipments
  has_many :site_messages
  belongs_to :province

  attr_accessible :address, :contact_name, :email, :in_every, :duration_type,
                  :land_line_number, :region, :town, :mobile,
                  :name, :number_of_deadline_sumission, :order_frequency, :order_start_at,
                  :service_type, :suggestion_order, :test_kit_waste_acceptable, :province_id,
                  :max_alert_deadline, :sms_alerted


  validates :contact_name,:land_line_number, :mobile, :name, :number_of_deadline_sumission, :order_frequency, :order_start_at,
            :service_type, :suggestion_order, :test_kit_waste_acceptable, :province_id , :presence   =>  true

  validates :order_frequency, :number_of_deadline_sumission, :numericality => {:greater_than => 0}
  validates :suggestion_order, :test_kit_waste_acceptable,  :numericality => {:greater_than_or_equal_to => 0 }
  validates :in_every, numericality: { greater_than: 0}

  SeviceType = ["ART", "HCT", "LOGISTICS UNIT", "Provincial Laboratory", 'PTTCT']
  Region = ['EHP', 'WHP', 'Momase', 'Southern']

  def deadline_date
    number_of_month = self.order_frequency.to_i
    number_of_day   = ((self.order_frequency - number_of_month) * 30).to_i

    next_order = self.order_start_at + number_of_month.month + number_of_day.day
    next_order + self.number_of_deadline_sumission.days
  end


  def deadline_for? now
    if(now > self.deadline_date )
      requisitions = self.requisition_reports.where(["requisition_reports.created_at BETWEEN :start AND :deadline",
                                                     :start => self.order_start_at.beginning_of_day, :deadline => self.deadline_date.end_of_day])
      return true if requisitions.size == 0
    end
    return false
  end

  def self.alert_requisition_report now
    return true if PublicHoliday.is_holiday?(now)

    Rails.logger.info "\nInfo requisitions #{now} ******* "
    sites = Site.alertable
    sites.each do |site|
      if site.deadline_for? now
        Rails.logger.info "\tAlert requisitions to site: #{site.name} @ #{now} "
        site.alert_dead_line
      else
        Rails.logger.info "\tSite: #{site.name} is not in deadline @ #{now} "
      end
    end
    Rails.logger.info "End\n"

  end

  def self.alertable
    where("sms_alerted < max_alert_deadline")
  end

  def alert_dead_line

    options = {
      :site => self.name,
      :deadline_date => self.deadline_date ,
    }

    setting = Setting[:message_deadline]
    translation = setting.str_tr options

    #send_via_nuntium message_item
    Sms.instance.send(
                      to: self.mobile.with_sms_protocol,
                      body: translation)

    log = {
      :site       => self,
      :shipment   => nil,
      :message    => translation,
      :to         => self.mobile,
      :sms_type   => SmsLog::SMS_TYPE_REQUISITION
    }
    SmsLog.create log
    self.inform_alert_deadline
  end

  def inform_alert_deadline
    self.sms_alerted = self.sms_alerted + 1
    self.save(:validate => false)
  end

  def inform_new_order
    self.order_start_at = Time.zone.now.to_date
    self.sms_alerted    = 0
    self.save
  end

end
