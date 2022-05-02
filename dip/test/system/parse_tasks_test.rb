require "application_system_test_case"

class ParseTasksTest < ApplicationSystemTestCase
  setup do
    @parse_task = parse_tasks(:one)
  end

  test "visiting the index" do
    visit parse_tasks_url
    assert_selector "h1", text: "Parse tasks"
  end

  test "should create parse task" do
    visit parse_tasks_url
    click_on "New parse task"

    fill_in "Category names", with: @parse_task.category_names
    fill_in "Finish date", with: @parse_task.finish_date
    fill_in "Name", with: @parse_task.name
    fill_in "Page urls", with: @parse_task.page_urls
    fill_in "Status", with: @parse_task.status
    fill_in "Web site", with: @parse_task.web_site
    click_on "Create Parse task"

    assert_text "Parse task was successfully created"
    click_on "Back"
  end

  test "should update Parse task" do
    visit parse_task_url(@parse_task)
    click_on "Edit this parse task", match: :first

    fill_in "Category names", with: @parse_task.category_names
    fill_in "Finish date", with: @parse_task.finish_date
    fill_in "Name", with: @parse_task.name
    fill_in "Page urls", with: @parse_task.page_urls
    fill_in "Status", with: @parse_task.status
    fill_in "Web site", with: @parse_task.web_site
    click_on "Update Parse task"

    assert_text "Parse task was successfully updated"
    click_on "Back"
  end

  test "should destroy Parse task" do
    visit parse_task_url(@parse_task)
    click_on "Destroy this parse task", match: :first

    assert_text "Parse task was successfully destroyed"
  end
end
