require 'test_helper'

class PrevalTest < Minitest::Test
  Dir[File.join(__dir__, 'cases', '*.test')].each do |filepath|
    define_method(:"test_#{File.basename(filepath, '.test')}") do
      input, output = File.read(filepath).split("---\n")
      assert_equal output, process(input)
    end
  end

  EXPECTED_EVENTS = %i[
    alias_error
    arg_ambiguous
    assign_error
    class_name_error
    excessed_comma
    heredoc_dedent
    magic_comment
    mlhs_new
    number_arg
    operator_ambiguous
    param_error
    parse_error
    stmts_new
  ]

  def test_event_types
    methods =
      (Ripper::PARSER_EVENTS - EXPECTED_EVENTS).map { |event| :"to_#{event}" }

    assert_empty methods - Preval::Node.instance_methods
  end

  def test_arithmetic
    assert_equal '7', inline('3 + 4')

    assert_equal 'a', inline('a + 0')
    assert_equal 'a', inline('0 + a')

    assert_equal 'a', inline('a * 1')
    assert_equal 'a', inline('1 * a')

    assert_equal 'a', inline('a ** 1')
    assert_equal '1', inline('1 ** a')

    assert_equal '1', inline('5 ** 0')
    assert_equal '-1', inline('-5 ** 0')
  end

  def test_loops_while_true
    input = <<~RUBY
      while true
        puts 'Hello, world!'
      end
    RUBY

    output = <<~RUBY
      loop do
      puts "Hello, world!"
      end
    RUBY

    assert_equal output, process(input)
  end

  def test_loops_for
    input = <<~RUBY
      for foo in [1, 2, 3]
        foo
      end
    RUBY

    output = <<~RUBY
      [1,2,3].each do |foo|
      foo
      end
    RUBY

    assert_equal output, process(input)
  end

  def test_micro
    assert_equal '[].reverse_each', inline('[].reverse.each')
    assert_equal 'foo.reverse_each', inline('foo.reverse.each')

    assert_equal 'Foo.reverse.each', inline('Foo.reverse.each')
  end

  private

  def inline(source)
    process(source).chomp
  end

  def process(source)
    Preval.process(source)
  end
end