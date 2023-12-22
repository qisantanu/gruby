module Admin::AuditLogHelper
  include ApplicationHelper
  def options_for_generated_by
    options = ['All Admins & System', 'System only', 'Admins only']

    dropdown_items = options.map do |item|
      if item == 'All Admins & System'
        filter_option(item, nil)
      else
        filter_option(item, item.parameterize.underscore)
      end
    end

    User.all.each do |user|
      dropdown_items << filter_option(user.name, user.id)
    end

    dropdown_items.join.html_safe
  end

  def options_for_module
    dropdown_items = [filter_option('All', nil)]
    ["Developers", "Apps", "Mails", "Reports", "Admins", "Settings", "Data Export"].each do |module_name|
      dropdown_items << filter_option(module_name, AUDIT_MODULE_MAPPER.fetch(module_name, module_name))
    end

    dropdown_items.join.html_safe
  end

  def filter_option(name, val)
    "<a class='dropdown-item js-log-filter' data-val='#{val}'>#{name.truncate(20)}</a>"
  end

  def options_for_date_range
    [['Entire Duration', nil], ['Today', 'today'], ['Yesterday', 'yesterday'], ['Last 7 Days', 7], ['Last 30 Days', 30], ['Last 60 Days', 60], ['Last 90 Days', 90], ['Custom Range', nil]].map do |item|
      date_range_option_for(item)
    end.join.html_safe
  end

  def date_range_option_for(item)
    case item[0]
    when 'Entire Duration'
      filter_option(item[0], nil)
    when 'Custom Range'
      "<a class='dropdown-item js-modal-open' data-modal-id='date_range_modal'>#{item[0]}</a>"
    when 'Today'
      date_filter_option(item[0], Time.now.to_s(:general))
    when 'Yesterday'
      date_filter_option(item[0], Time.now.yesterday.to_s(:general))
    else
      start_date = (item[1]-1).days.ago.to_s(:general)
      end_date = Time.now.to_s(:general)
      date_range = [start_date, end_date].join(' - ')
      date_filter_option(item[0], date_range)
    end
  end

  def date_filter_option(name, val)
    "<a class='dropdown-item js-date-filter' data-val='#{val}'>#{name}</a>"
  end

  def formatted_log_timestamp(log)
    formatted_timestamp(log.created_at)
  end

  def formatted_log_value(val, key, user, mod)
    return (val.to_s(:general) + "<span class='dot'></span>" + val.strftime("%I:%M %p")).html_safe if val.is_a?(Time)
    return formatted_value(val, key, user, mod)
  end

  def formatted_tooltip_value(val, key, user, mod)
    return  (val.to_s(:general) + "." + val.strftime("%I:%M %p")) if val.is_a?(Time)
    return formatted_value(val, key, user, mod)
  end

  def formatted_value(val, key, user, mod)
    if (key == "email" && mod == "Developer")
      return masking_text_for_user(user, val, :email)
    end
    if (key == "contact" && mod == "Developer")
      return  masking_text_for_user(user, val, :contact)
    end
    return val if val == "Total SDK Activations"
    return val if val == "TDCID Notification"
    return val if val == "ERP"
    return val if val == "e-Services URL"
    return "TDCID Data" if val == "tdcid_data"
    return "ERP Data" if val == "erp_data"
    return val.join(", ") if val.is_a?(Array)
    return val if val.is_a?(Integer)
    return val.to_s.try(:titleize) if val.in? [true, false]
    if key == "sending_email"
      return val ? "Allowed" : "Not Allowed"
    end
    return val if key.in?(["bundle_id","email","company","sender","date_range","description","val"])
    return val.sub(/\S/, &:upcase) if key == "name"
    return (val.try(:titleize) if val.present?) unless val.is_a?(Time)
  end

  def formatted_key(key)
    case key
    when "contact"
      'Phone Number'
    when "purpose"
      'Purpose of Usage'
    when "val_type"
      'Value Type'
    when "val"
      'Value'
    when 'developers_emails'
      'Developer email IDs'
    when 'sign_in_at'
      'Sign In at'
    when 'sent_at'
      'Sent at'
    when 'sdk_account_key'
      'SDK Account Key'
    when 'created_at'
      'Created at'
    when 'id'
      'ID'
    when "sdk_activation_date_range"
      "SDK Activation for"
    when "bundle_id"
      "Bundle ID"
    when "last_active_at"
      "Last Active at"
    else
      key.titleize
    end
  end

  def generated_by_system
    "<span class='by-system'>System</span>".html_safe
  end
end
