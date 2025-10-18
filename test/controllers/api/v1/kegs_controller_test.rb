require "test_helper"

class Api::V1::KegsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_kegs_index_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_kegs_show_url
    assert_response :success
  end
end
