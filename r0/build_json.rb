require_relative "page"
require "json"

test_data = EXAMPLES.map.with_index do |e,ix|
  {
    number: ix,
    src: e,
    expected: solve(e),
  }
end

puts ( {
  event_id: "R0",
  test_data: test_data,
}.to_json )


  