require "test_helper"

class KegsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get kegs_index_url
    assert_response :success
  end

  test "should get show" do
    get kegs_show_url
    assert_response :success
  end

  test "should get new" do
    get kegs_new_url
    assert_response :success
  end

  test "should get create" do
    get kegs_create_url
    assert_response :success
  end

  test "should get edit" do
    get kegs_edit_url
    assert_response :success
  end

  test "should get update" do
    get kegs_update_url
    assert_response :success
  end

  test "should get destroy" do
    get kegs_destroy_url
    assert_response :success
  end
end
