require "test_helper"

class Api::V1::DrinksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_drinks_create_url
    assert_response :success
  end
end
