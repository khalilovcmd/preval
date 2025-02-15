require 'test_helper'

class FastererTest < Minitest::Test
  def test_reverse_each
    assert_change '[].reverse.each', '[].reverse_each'
    assert_change 'foo.reverse.each', 'foo.reverse_each'
    refute_change 'Foo.reverse.each'
  end

  def test_gsub_tr
    assert_change 'foo.gsub("a", "b")', 'foo.tr("a", "b")'
  end

  def test_shuffle_first
    assert_change '[].shuffle.first', '[].sample'
    assert_change 'foo.shuffle.first', 'foo.sample'
    refute_change 'Foo.shuffle.first'
  end

  def test_map_flatten
    assert_change '[].map { |x| x }.flatten(1)', '[].flat_map { |x|x }'
    assert_change 'foo.map { |x| x }.flatten(1)', 'foo.flat_map { |x|x }'
    refute_change 'Foo.map { |x|x }.flatten(1)'
  end
end
