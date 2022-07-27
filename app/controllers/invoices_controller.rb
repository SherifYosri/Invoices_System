class InvoicesController < ApplicationController
  before_action :authenticate_user!, except: :home

  def upload
    render :import and return unless attach_invoices_file
    enqueue_invoices_file_processing
  end

  def index
    @invoices = current_user.invoices.paginate per_page: 10, page: params[:page]
  end

  private

  def attach_invoices_file
    uploaded_file = params[:invoices]
    current_user.errors.add(:invoices_file, :blank) and return false if uploaded_file.blank?
    current_user.invoices_file.attach(uploaded_file)
  end

  def enqueue_invoices_file_processing
    InvoicesProcessingJob.perform_later(current_user.id, Date.today)
  end
end
