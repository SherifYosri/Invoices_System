require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get invoices_home_url
    assert_response :success
  end
end
