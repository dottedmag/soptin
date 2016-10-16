# LICENSE: MIT (see LICENSE)
require 'test/unit'
require './sorter'

class TestDiff < Test::Unit::TestCase
  def test_diff
    old = [0, 1, 2, 3, 4]
    new = Set.new([1, 3, 0, 6, -1])
    exp = {new: [0, 1, 3, -1, 6], added: [-1, 6], removed: [2, 4]}
    assert_equal(exp, diff(old, new))
  end
end
