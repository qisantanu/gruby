module Admin::SearchHelper
  def search_results(developers = [], apps = [], users = [], emails = [])
    [{ name: 'user', count: users.try(:total_count).to_i },
     { name: 'email', count: emails.try(:total_count).to_i },
     { name: 'app', count: apps.try(:total_count).to_i },
     { name: 'developer', count: developers.try(:total_count).to_i }
    ].sort_by { |t| t[:count] }.reverse
  end

  def search_tab_name(tab_name)
    return 'ADMINS' if tab_name == 'user'
    return 'MAILS' if tab_name == 'email'
    tab_name.pluralize.capitalize
  end

  def search_tab_icon_tag(tab_name)
    icon = (tab_name == 'email' ? 'mail' : tab_name)
    svg_icon_tag(icon, { class: 'icon-sm' })
  end

  def search_count(items, item_type)
    return if items.blank?
    "<strong>#{items.total_count}</strong>".html_safe
  end

  def formatted_search_term(term)
    search_term = term.gsub('%','\%').gsub('_','\_')
   "%#{search_term.try(:strip)}%".downcase
  end
end
