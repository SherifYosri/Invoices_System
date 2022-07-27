class Invoice < ApplicationRecord
  belongs_to :user
  validates :internal_id, numericality: { only_integer: true }
  validates :amount, numericality: true
  validate :valid_due_on_date

  def self.calculate_selling_price amount, due_on_date, invoice_uploading_date
    due_on_date = parse_dates due_on_date
    return nil if amount.blank? || due_on_date.blank?
    
    discount = if invoice_uploading_date < due_on_date
      (due_on_date - invoice_uploading_date).to_i > 30 ? 0.5 / 100.0 : 0.3 / 100.0
    else
      0
    end

    amount - ( amount * discount )
  end

private

  def valid_due_on_date
    error_msg = if self.due_on_date.blank?
      "must exist"
    elsif self.class.parse_dates(self.due_on_date).blank?
      "is not a valid date"
    end
    self.errors.add(:due_on_date, error_msg) if error_msg.present?
  end

  def self.parse_dates date
    begin
      Date.parse date
    rescue Date::Error
      nil
    end
  end
end
