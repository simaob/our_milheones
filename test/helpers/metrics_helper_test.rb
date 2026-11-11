require 'test_helper'

class MetricsHelperTest < ActionView::TestCase
  test "euros" do
    assert_equal "€1,234.50", euros(1234.5)
    assert_equal "−€12.00", euros(-12)
    assert_equal "+€3.00", euros(3, signed: true)
    assert_equal "€0.00", euros(-0.001, signed: true)
  end

  test "returns read as gains or losses" do
    assert_equal "−76%", percent(-0.76)
    assert_equal "+5%", percent(0.05, signed: true)
    assert_equal "0%", percent(-0.004, signed: true)
    assert_equal "—", percent(nil)
    assert_equal '<td class="num text-danger">−76%</td>', return_tag(-0.76, :td, class: "num")
    assert_equal '<span class="text-success">+177%</span>', return_tag(1.77)
  end

  test "chart ticks are round and cover the maximum" do
    assert_equal [0, 50, 100, 150], chart_ticks(130)
    assert_equal [0, 2.5, 5, 7.5, 10], chart_ticks(8.5)
    assert_equal [0, 1], chart_ticks(0)
  end
end
