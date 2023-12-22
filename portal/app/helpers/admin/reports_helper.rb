module Admin::ReportsHelper
  def options_for_select_report
    activations = [{ type: 'distinct_activations', periodical: true }, { type: 'total_sdk_activations', periodical: true }]
    applications = [{ type: 'blacklisted_applications' }, { type: 'reinstated_applications' }, { type: 'registered_applications' }]
    developers = [{ type: 'total_registered_developers', periodical: true }, { type: 'registered_developers' }, { type: 'blacklisted_developers' }, { type: 'reinstated_developers' }]
    [activations, applications, developers]
  end

  def options_for_report_date_range
    [%w[Today today], %w[Yesterday yesterday], ['Last 7 Days', 7], ['Last 30 Days', 30], ['Last 60 Days', 60], ['Last 90 Days', 90], ['Custom Range', nil]].map do |item|
      date_range_option_for(item)
    end.join.html_safe
  end

  def tooltip_for_report(type)
    case type
    when 'distinct_activations'
      "This report provides a count of total number of unique applications that have been used each day within a selected range."
    when 'total_sdk_activations'
      "This report provides a count of number of times all the applications have been used."
    when 'blacklisted_applications'
      "This report provides a list of Apps that are currently Blacklisted."
    when 'reinstated_applications'
      "This report provides a list of Apps that are currently Active after it was Blacklisted."
    when 'registered_applications'
      "This report provides a list of Apps that are currently registered with DataMall."
    when 'total_registered_developers'
      "This report provides a daily count of Developer registered on that day."
    when 'registered_developers'
      "This report provides a list of Developers that are currently registered with DataMall."
    when 'blacklisted_developers'
      "This report provides a list of Developers that are currently Blacklisted."
    when 'reinstated_developers'
      "This report provides a list of Developers that are currently Active after it was Blacklisted."
    end
  end
end
