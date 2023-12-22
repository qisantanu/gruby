module Admin::EmailsHelper
  def image_attach(image)
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/#{image}")
    attachments['logo.png'].url
  end

  def developer_guide_url
    'https://datamall.lta.gov.sg/content/dam/datamall/pdf/Extended_OBU_Library_SDK_Developer_Guide.pdf'
  end
end
