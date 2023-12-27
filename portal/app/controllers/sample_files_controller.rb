require 'quartz'
require File.join(File.dirname(__FILE__), '../../lib/colorize')

class SampleFilesController < ApplicationController
  layout 'sample_layout'

  def index
    @time_taken = params[:time_taken]
  end

  def create
    start_time = Time.zone.now
    lines = params[:form][:number_of_lines].to_i

    if params[:form][:lang].present? && params[:form][:lang] == 'ruby'
      color = 'red'
      ObuDetail.generate_sample_file(lines)
      @sample_file = File.read(Rails.root.join('samples', 'test.txt'))
    else
      color = 'blue'
      client = Quartz::Client.new(bin_path: Rails.root.join('go_scripts', 'populate_sample_file').to_s)
      client[:populate_sample_file].call('FileGenerate', 'Lines'=> lines)
      @sample_file = File.read(Rails.root.join('samples', 'test_with_go.txt'))
    end

    @time_taken = "#{Time.zone.now - start_time} secs taken during the last process"
    Rails.logger.debug(@time_taken.colorize(color, bg: true, style: :bold))
    send_data @sample_file,  text: 'sample_file.text', type: 'application/text', disposition: 'attachment; filename=sample_file.text'
  rescue StandardError => e
    redirect_to sample_files_path, alert: e.message
  end
end
