require_relative 'helper'
require 'fluent/test'
require 'fluent/plugin/out_named_pipe'
require 'ruby-fifo'

Fluent::Test.setup

class NamedPipeOutputTest < Test::Unit::TestCase
  TEST_PATH = "out_named_pipe"

  setup do
    @tag = 'foo.bar'
  end

  teardown do
    File.unlink(TEST_PATH) rescue nil
  end

  def create_driver(conf)
    Fluent::Test::OutputTestDriver.new(Fluent::NamedPipeOutput, @tag).configure(conf)
  end

  sub_test_case 'configure' do
    test 'required parameter' do
      assert_raise_message("'path' parameter is required") do
        create_driver('')
      end

      d = create_driver(%[path #{TEST_PATH}])
      assert_equal TEST_PATH, d.instance.path
    end

    test 'option parameter' do
      config = %[
        path #{TEST_PATH}
      ]
      d = create_driver(config + %[format ltsv])
      assert_equal TEST_PATH, d.instance.path
    end
  end

  sub_test_case 'write' do
    CONFIG = %[
      path #{TEST_PATH}
      format ltsv
    ]
    
    test 'reader is waiting' do
      readline = nil
      thread = Thread.new {
        pipe = Fifo.new(TEST_PATH, :r, :wait)
        readline = pipe.readline
      }

      d = create_driver(CONFIG)
      d.run do
        d.emit({'foo' => 'bar'})
      end

      thread.join
      assert_equal "foo:bar\n", readline
    end

    test 'reader is not waiting' do
      d = create_driver(CONFIG)
      assert_nothing_raised do
        d.emit({'foo' => 'bar'})
      end
    end
  end
end
