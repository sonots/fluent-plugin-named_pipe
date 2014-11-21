require_relative 'helper'
require 'fluent/test'
require 'fluent/plugin/in_named_pipe'

class NamedPipeInputTest < Test::Unit::TestCase
  TEST_PATH = 'in_named_pipe'

  setup do
    Fluent::Test.setup
  end

  teardown do
    File.unlink(TEST_PATH) rescue nil
  end

  def create_driver(conf)
    Fluent::Test::InputTestDriver.new(Fluent::NamedPipeInput).configure(conf)
  end

  sub_test_case 'configure' do
    test 'required parameters' do
      assert_raise_message("'path' parameter is required") do
        create_driver(%[
          tag foo
        ])
      end

      assert_raise_message("'tag' parameter is required") do
        create_driver(%[
          path #{TEST_PATH}
        ])
      end
    end
  end

  sub_test_case "emit" do
    CONFIG = %[
      path #{TEST_PATH}
      tag named_pipe
      format ltsv
    ]

    test 'read and emit' do
      d = create_driver(CONFIG)
      d.run {
        pipe = Fifo.new(TEST_PATH, :w, :nowait)
        pipe.write "foo:bar\n"
      }

      emits = d.emits
      emits.each do |tag, time, record|
        assert_equal("named_pipe", tag)
        assert_equal({"foo"=>"bar\n"}, record)
      end
    end
  end
end

