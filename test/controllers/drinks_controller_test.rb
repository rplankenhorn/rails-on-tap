require "test_helper"

class DrinksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get drinks_index_url
    assert_response :success
  end

  test "should get show" do
    get drinks_show_url
    assert_response :success
  end
end
