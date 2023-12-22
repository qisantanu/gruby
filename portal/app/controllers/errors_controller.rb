class ErrorsController < ApplicationController
  def not_found
    layout = 'sample_layout'

    render(:status => 404, layout: layout)
  end

  def internal_server_error
    layout = 'sample_layout'
    render(:status => 500)
  end
end
