require 'test_helper'

class MetricsHelperTest < ActionView::TestCase
  test "euros" do
    assert_equal "€1,234.50", euros(1234.5)
    assert_equal "−€12.00", euros(-12)
    assert_equal "+€3.00", euros(3, signed: true)
    assert_equal "€0.00", euros(-0.001, signed: true)
  end

  test "chart ticks are round and cover the maximum" do
    assert_equal [0, 50, 100, 150], chart_ticks(130)
    assert_equal [0, 2.5, 5, 7.5, 10], chart_ticks(8.5)
    assert_equal [0, 1], chart_ticks(0)
  end
end
