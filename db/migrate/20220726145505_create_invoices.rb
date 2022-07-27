class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.string :internal_id
      t.string :amount
      t.string :due_on_date
      t.decimal :selling_price, precision: 15, scale: 10
      t.belongs_to :user

      t.timestamps
    end
  end
end
