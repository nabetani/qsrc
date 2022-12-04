EXAMPLE_INPUT="3,5,7,4,12,6,2,8,9,5,6"

def one_example(seed)
  rng = Random.new(seed)
  size = rng.rand(20)+4
  ceil = (2**(rng.rand(30..60)/10.0)).floor
  nums = Array.new(size){ rng.rand(1..ceil) }
  max = nums.max
  $stderr.puts( {size:size, ceil:ceil, max:max, nums:nums}.inspect )
  while nums.count(max) != 1 do
    nums[nums.index(nums.max)] -= rng.rand(1..(max-1))
  end
  nums.join(",")
end

def examples
  [
    EXAMPLE_INPUT,
    "5,8,7,11,1,3,2,8,12,4,6,10",
    *Array.new(20){|ix| one_example(ix)},
  ]
end

EXAMPLES = examples
