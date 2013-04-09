require 'helper'

class ListFilterOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    @obj = Fluent::ListFilterOutput.new
  end

  CONF = %[
      type list_filter
      tag "test." + tag
      path sample/list.yml
      filter_type allow
    ]

  def create_driver(conf=CONF, tag='test.input')
    Fluent::Test::OutputTestDriver.new(Fluent::ListFilterOutput, tag).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal "\"test.\" + tag", d.instance.tag
    assert_equal "sample/list.yml", d.instance.path
    assert_equal "allow", d.instance.filter_type
  end
end
