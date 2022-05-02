require "test_helper"

class LitresBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get parse" do
    get litres_books_parse_url
    assert_response :success
  end

  test "should get delete" do
    get litres_books_delete_url
    assert_response :success
  end
end
