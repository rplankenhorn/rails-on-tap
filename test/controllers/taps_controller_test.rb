require "test_helper"

class TapsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get taps_index_url
    assert_response :success
  end

  test "should get show" do
    get taps_show_url
    assert_response :success
  end

  test "should get new" do
    get taps_new_url
    assert_response :success
  end

  test "should get create" do
    get taps_create_url
    assert_response :success
  end

  test "should get edit" do
    get taps_edit_url
    assert_response :success
  end

  test "should get update" do
    get taps_update_url
    assert_response :success
  end
end
