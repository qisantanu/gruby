module ApplicationHelper
  def sortable(object_type, column, title = nil, params)

    sort_column = params[:sort].present? ? params[:sort] : DEFAULT_SORT_COLUMN[object_type]
    sort_direction = params[:direction].present? ? params[:direction] : DEFAULT_SORT_DIRECTION[object_type]

    params_list = { sort: column, direction: col_sort_direction(column, sort_column, sort_direction) }
    [:generated_by, :module_name, :date_range, :query, :status, :recipient].each do |filter_param|
      params_list.merge!(filter_param => params[filter_param]) if params[filter_param].present?
    end

    path = case object_type
            when 'Developer'
              if params[:controller] == 'admin/search'
                admin_developers_search_path(params_list)
              else
                admin_developers_path(params_list)
              end
            when 'Application'
              if params[:controller] == 'admin/search'
                admin_apps_search_path(params_list)
              else
                admin_apps_path(params_list)
              end
            when 'User'
              if params[:controller] == 'admin/search'
                admin_users_search_path(params_list)
              else
                admin_users_path(params_list)
              end
            when 'Email'
              if params[:controller] == 'admin/search'
                admin_emails_search_path(params_list)
              else
                admin_emails_path(params_list)
              end
            when 'AuditLog'
              admin_audit_log_index_path(params_list)
            end


    # path =  url_for(params_list)

    title ||= column.to_s.titleize
    css_class = column.to_s == sort_column.to_s ? "sorted #{sort_direction}" : nil
    direction = column.to_s == sort_column.to_s && sort_direction == "asc" ? "desc" : "asc"
    dirc = column.to_s == sort_column.to_s && sort_direction == "asc" ? "up" : "down"
    dir =  column.to_s == sort_column.to_s ? dirc : nil

    svg_tag = content_tag 'span', { class: 'sorting-caret' } do
      "<span class='sorted-caret #{dir}'></span>".html_safe
      #svg_icon_tag('caret')
    end

    content_tag(:a, href: path, class: "#{css_class}sort-now js-sort-by-column", remote: true) do
      (title + svg_tag).html_safe
    end
  end

  def svg_icon_tag(icon, options={})
    klasses = ['icon', "icon-#{icon}"]
    klasses = klasses.concat(options[:class].split(',')).flatten if options[:class].present?
    content_tag :i, { class: klasses.join(' ') } do
    end
  end

  def col_sort_direction(column, sort_column, sort_direction)
    column.to_s == sort_column && sort_direction == "asc" ? "desc" : "asc"
  end

  def left_nav_class(page_type)
    is_active = case page_type
                when 'home'
                  params[:controller] == "admin/dashboard"
                when 'developer'
                  params[:controller] == "admin/developers"
                when 'app'
                  params[:controller] == "admin/apps"
                when 'user'
                  params[:controller] == "admin/users"
                when 'mail'
                  params[:controller] == "admin/emails"
                when 'report'
                  params[:controller] == "admin/reports"
                when 'audit_log'
                  params[:controller] == "admin/audit_log"
                when 'settings'
                  params[:controller] == "admin/settings"
                end

    'active' if is_active
  end

  def selected_search_type(params)
    case params[:controller]
    when "admin/developers"
      'Developers'
    when "admin/apps"
      'Apps'
    when "admin/users"
      'Admins'
    when "admin/emails"
      'Mails'
    when "admin/search"
      case params[:action]
      when 'developers_search'
        'Developers'
      when 'apps_search'
        'Apps'
      when 'users_search'
        'Admins'
      when 'emails_search'
        'Mails'
      else
        'All'
      end
    else
      'All'
    end
  end

  def selected_search_path(params)
    case params[:controller]
    when "admin/developers"
      admin_developers_search_path
    when "admin/apps"
      admin_apps_search_path
    when "admin/users"
      admin_users_search_path
    when "admin/emails"
      admin_emails_search_path
    when "admin/search"
      case params[:action]
      when 'developers_search'
        admin_developers_search_path
      when 'apps_search'
        admin_apps_search_path
      when 'users_search'
        admin_users_search_path
      when 'emails_search'
        admin_emails_search_path
      else
        admin_all_search_path
      end
    else
      admin_all_search_path
    end
  end


  def filter_path(type, search_page = false, search_all = false)
    path = case type
            when "developer"
              return admin_developers_path if search_all.blank? && search_page.blank?
              admin_developers_search_path
            when "app"
              return admin_apps_path if search_all.blank? && search_page.blank?
              admin_apps_search_path
            when "user"
              return admin_users_path if search_all.blank? && search_page.blank?
              admin_users_search_path
            when "mail"
              return admin_emails_path if search_all.blank? && search_page.blank?
              admin_emails_search_path
            end

    search_all ? admin_all_search_path : path
  end

  def status_list(type)
    obj_types = { developer: Developer, app: Application, user: User }
    obj_types[type.to_sym].statuses
  end

  def link_to_close_modal
    link_to 'javascript:;', class: "close-details js-close-detail", title: 'Close' do
      svg_icon_tag('cross')
    end
  end

  def link_to_close_message
    link_to 'javascript:;', class: "close-details js-close-message" do
      svg_icon_tag('cross', { class: 'icon-xs' })
    end
  end

  def pagination_count(paginated_list)
    start_point = paginated_list.current_per_page * (paginated_list.current_page - 1)
    return "0 - 0 of 0" if paginated_list.total_count.zero?

    "#{start_point + 1} - #{start_point + paginated_list.count} of #{paginated_list.total_count}"
  end

  def status_button_tooltip(item, status = nil)
    if item.is_a?(User)
      "Change status to #{USER_STATUS_BUTTON_VALUE[item.status].capitalize}"
    else
      "Change status to #{STATUS_BUTTON_VALUE[item.status].capitalize}"
    end
  end

  def has_permission?(path, method = :get)
    current_user.has_permission?(Rails.application.routes.recognize_path(path, method: method))
  end

  def status_action_path_for(object, status = nil)
    if object.is_a?(Developer)
      update_status_admin_developer_path(object, status: STATUS_BUTTON_VALUE[object.status])
    elsif object.is_a?(Application)
      update_status_admin_app_path(object, status: STATUS_BUTTON_VALUE[object.status])
    elsif object.is_a?(User)
      update_status_admin_user_path(object, status: USER_STATUS_BUTTON_VALUE[status || object.status])
    end
  end

  def masking_text(text, type = nil)
    masking_text_for_user(current_user, text, type)
  end

  def masking_text_for_user(user, text, type = nil)
    return text if user.super_admin?
    return text if text.length < 3

    if type == :email
      pre_alpha = text.split('@').first
      pre_alpha =  masking_text_for_user(user,pre_alpha)
      post_alpha = text.split('@').last
      post_alpha_domains = post_alpha.split('.')
      post_alpha_domains = post_alpha_domains.map { |p| masking_text_for_user(user, p) }
      post_alpha_domains = post_alpha_domains.join('.')
      pre_alpha + '@' + post_alpha_domains
    else
      text[0] + '*' * (text[1...-1].length) + text[-1]
    end
  end

  def link_to_download_report(type, period = nil)
    return if type.blank?

    if period.present?
      link_to "#{period}d", cloudfront_redirect_url(download_admin_reports_path(type: type, days: period, format: :csv))
    else
      link_to 'Download', cloudfront_redirect_url(download_admin_reports_path(type: type, format: :csv))
    end
  end

  def formatted_error_message(obj, field)
    if obj.errors.details[field].include?({:error=>:blank})
      if obj.is_a?(Email)
        if field == :subject
          return "Please enter a Subject"
        elsif field == :body
          return "Message can't be empty."
        else
          return "can't be blank"
        end
      end
    end
    obj.errors[field].to_sentence
  end

  def formatted_password_error(obj, field, params)
    user_params = params.dig(:user) || {}
    if field == :old_password
      if user_params[:old_password].blank?
        "Please enter Old Password"
      else
        obj.errors[field].to_sentence
      end
    elsif field == :password_confirmation
      if (user_params[:password].blank? || user_params[:password_confirmation].blank?)
        "Please fill the required field(s)"
      else
        if(user_params[:password] != user_params[:password_confirmation])
          if (params[:action] == "update_password")
            "Confirm Password and New Password must be the same."
          else
            "Password and Confirm Password must be the same."
          end
        else
          obj.errors[field].to_sentence
        end
      end

    else
      obj.errors[field].to_sentence
    end
  end

  def confirmation_content(obj, action)

    if obj.is_a?(Developer) || obj.is_a?(Application)
      if action == 'Blacklist'
        "<span>Do you wish to #{action} </span> <strong class='word-wrap'>#{obj.name}</strong>?"
      else
        "<span>Do you wish to change the status to #{action} for</span> <strong class='word-wrap'>#{obj.name}</strong>?"
      end
    elsif  obj.invited?
      "<span>Do you wish to Revoke the admin invitation of </span> <strong class='word-wrap'>#{obj.name}</strong>?"
    else
      "<span>Do you wish to change the status to #{action} for</span> <strong class='word-wrap'>#{obj.name}</strong>?"
    end
  end

  def confirmation_reason_form(obj, action)
    if action.in?(['Blacklist', 'Activate','Re-Invite','Deactivate','Revoke']) && (obj.is_a?(Developer) || obj.is_a?(Application)|| obj.is_a?(User))
      '<div class="form-group reason-for-action">
        <textarea name="reason" id="reason" class="form-control confirmation-reason" placeholder="Enter Reason"></textarea>
        '+ svg_icon_tag('small-info', { class: 'icon-sm' }) +'
      </div>'
     end
  end

  def confirmation_title(obj, action_type)
    "#{MODULE_MAPPER[obj.class.to_s]} #{action_type}"
  end

  def confirmation_button(obj, action_type = 'Yes')
    btn_class = action_type.in?(['Blacklist', 'Deactivate']) ? 'btn-danger' : 'btn-primary'
    '<button name="button" type="submit" class="btn ' + btn_class + '" id="confirm_ok_button">' + action_type + '</button>'
  end

  def status_change_confirmation_button(obj, action_type = 'Yes')
    btn_class = action_type.in?(['Blacklist', 'Deactivate']) ? 'btn-danger' : 'btn-primary'
    '<button name="button" type="submit" class="btn ' + btn_class + '" id="status_change_confirm_button">' + action_type + '</button>'
  end

  def page_name(params)
    case params[:controller]
    when "admin/developers"
      'developers'
    when "admin/apps"
      'apps'
    when "admin/users"
      'users'
    when "admin/emails"
      'mails'
    when "admin/audit_log"
      'audit log'
    end
  end

  def current_status_span(obj)
    current_status_class = overlay_status_class(obj)

    return "<span class='current-status #{current_status_class}-text'>#{obj.status}</span>".html_safe
  end

  def overlay_status_class(obj)
    if obj.is_a?(User)
      USER_STATUS_CSS[obj.status]
    elsif obj.is_a?(Application)
      if obj.active? && obj.developers_not_active?
        "developer-not-active"
      else
        STATUS_CSS[obj.status]
      end
    else
      STATUS_CSS[obj.status]
    end
  end

  def has_error_of_type(obj, field, type)
    obj.errors.details[field].map { |i| i[:error] }.include?(type)
  end

  def status_change_state(index)
    text = if index.zero?
             "Current state"
           elsif (index == 1)
             "Previous state(s)"
           end

    content_tag 'span', text, class: "state-group"
  end

  def valid_password?(obj)
    return false if obj.password.blank? || obj.password_confirmation.blank?
    return false if obj.password != obj.password_confirmation
    return false if PASSWORD_FORMAT_MAPPER.keys.any? { |type| has_error_of_type(obj, :password, type) }
    true
  end

  def formatted_timestamp(timestamp)
    return if timestamp.blank?
    (timestamp.to_s(:general) + "<span class='dot'></span>" + timestamp.strftime("%I:%M %p")).html_safe
  end

  def status_reason_text(log, obj = nil)
    if (obj.is_a?(User))
      status = User.statuses[log.changeset[:status].try(:last)]

      if status == User::DEACTIVATED
        log.changeset[:deactivated_reason].try(:last)
      elsif status == User::REVOKED
        log.changeset[:revoked_reason].try(:last)
      elsif status == User::INVITED
        log.changeset[:invited_reason].try(:last)
      end
    else
      status = Developer.statuses[log.changeset[:status].try(:last)]

      if status == Developer::BLACKLISTED
        log.changeset[:blacklisted_reason].try(:last)
      elsif status == Developer::ACTIVE
        log.changeset[:reinstated_reason].try(:last)
      elsif status == Developer::DEACTIVATED
        log.changeset[:deactivated_reason].try(:last)
      end
    end
  end
end
