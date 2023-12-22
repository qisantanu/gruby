module Admin::AppsHelper
  def developer_list(app)
    developers_names = app.developers.map(&:name)
    return developers_names.first if developers_names.count < 2
    first_dev = h(developers_names.first.dup.to_s)
    first_dev.concat("<span class='apps-list_developer_count'> (+#{developers_names.count - 1} more)</span>".html_safe)
  end
end
