require "test_helper"

class ParseTasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parse_task = parse_tasks(:one)
  end

  test "should get index" do
    get parse_tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_parse_task_url
    assert_response :success
  end

  test "should create parse_task" do
    assert_difference("ParseTask.count") do
      post parse_tasks_url, params: { parse_task: { category_names: @parse_task.category_names, finish_date: @parse_task.finish_date, name: @parse_task.name, page_urls: @parse_task.page_urls, status: @parse_task.status, web_site: @parse_task.web_site } }
    end

    assert_redirected_to parse_task_url(ParseTask.last)
  end

  test "should show parse_task" do
    get parse_task_url(@parse_task)
    assert_response :success
  end

  test "should get edit" do
    get edit_parse_task_url(@parse_task)
    assert_response :success
  end

  test "should update parse_task" do
    patch parse_task_url(@parse_task), params: { parse_task: { category_names: @parse_task.category_names, finish_date: @parse_task.finish_date, name: @parse_task.name, page_urls: @parse_task.page_urls, status: @parse_task.status, web_site: @parse_task.web_site } }
    assert_redirected_to parse_task_url(@parse_task)
  end

  test "should destroy parse_task" do
    assert_difference("ParseTask.count", -1) do
      delete parse_task_url(@parse_task)
    end

    assert_redirected_to parse_tasks_url
  end
end
