module Admin::DevelopersHelper
  def app_list(developer)
    app_names = developer.applications.pluck(:name)
    return app_names.first if app_names.count < 2
    first_app = h(app_names.first.dup.to_s)
    first_app.concat("<span class='developers-list_app_count'> (+#{app_names.count - 1} more)</span>".html_safe)
  end

  def convert_to_human_readable(number)
    if (number >= 1000)
      number_to_human(number, precision:2, units: { million: 'M', thousand: 'K', billion: 'B'}).gsub(' ', '')
    else
      number
    end
  end

  def link_to_resend_account_key(developer)
    link_to 'Resend SDK Account key', "javascript:",
              data: {
                url: resend_account_key_admin_developer_path(developer),
                modal_title: "Resend SDK Account key",
                modal_content: "Do you wish to resend SDK Account Key to <strong class='word-wrap'>#{developer.name.titlecase}</strong>?"
              },
              title: 'Resend SDK Account Key',
              class: "btn btn-secondary btn-sm #{'disabled' if developer.blacklisted?} js-confirm-action resend-account-key"
  end
end
