module Admin::DataExportHelper
  def module_name(a)
    a.map!{ |x| x == "activations" ? "SDK Activation" : x.titleize }
  end
end