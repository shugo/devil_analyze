require "statsample"
require "json"

devils = JSON.parse(ARGF.read)
obj_name = "防御"
exp_names = ["体", "速"]
h = ([obj_name] + exp_names).each_with_object({}) { |name, h|
  h[name] = devils.map {|i| i[name]}
}
puts Statsample::Regression.multiple(h.to_dataset, obj_name).summary
