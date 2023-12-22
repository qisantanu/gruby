class ApplicationController < ActionController::Base
  def redirect_to_options(opts = {})
    opts.merge({ protocol: determine_protocol })
  end

  def determine_protocol
    Rails.env.development? || Rails.env.test? ? 'http' : 'https'
  end

  def cloudfront_redirect_url(path)
    if Rails.env.development?
      URI::HTTP.build(host: ENV['PORTAL_DOMAIN'], path: path, port: 3000).to_s
    elsif Rails.env.test?
      URI::HTTP.build(host: 'test.host', path: path).to_s
    else
      URI::HTTPS.build(host: ENV['PORTAL_DOMAIN'], path: path).to_s
    end

    # "#{determine_protocol}://#{determine_host}#{path}"
  end

  helper_method :redirect_to_options, :cloudfront_redirect_url
end
