require "test_helper"

class Admin::KegsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_kegs_index_url
    assert_response :success
  end
end
