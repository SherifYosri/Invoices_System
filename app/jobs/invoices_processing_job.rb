class InvoicesProcessingJob < ApplicationJob
  queue_as :medium

  def perform(user_id, uploading_date)
    @uploading_date = uploading_date
    @user = User.find user_id
    return unless @user.invoices_file.attached?
    
    process_csv_file ActiveStorage::Blob.service.send(:path_for, @user.invoices_file.key)
  end

  private
  
  def process_csv_file path
    require 'csv'
    options = { skip_blanks: true, skip_lines: ',,' }
    batch_size = 1000
    parsed_rows = []
    CSV.foreach(path, options).with_index(1) { |row, idx|
      parsed_rows << parse_csv(row)
      
      if idx % batch_size == 0
        Invoice.insert_all parsed_rows
        parsed_rows.clear
      end
    }
    # Insert remaining not inserted rows
    Invoice.insert_all parsed_rows
  end

  def parse_csv row
    amount = Float row[1] rescue nil
    selling_price = Invoice.calculate_selling_price amount, row[2], @uploading_date
    
    { 
      internal_id: row[0], 
      amount: row[1], 
      due_on_date: row[2], 
      selling_price: selling_price,
      user_id: @user.id, 
      created_at: Time.now, 
      updated_at: Time.now
    }
  end
end