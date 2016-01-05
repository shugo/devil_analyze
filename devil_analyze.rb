require "statsample"
require "json"

include Statsample

devils = JSON.parse(ARGF.read)
obj_name = "防御"
exp_names = ["体", "速"]
h = exp_names.each_with_object({
  obj_name => devils.map {|i| i[obj_name]}
}) { |name, h|
  h[name] = devils.map {|i| i[name]}
}
puts Statsample::Regression.multiple(h.to_dataset, obj_name).summary
