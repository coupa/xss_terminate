class TextSanitizerTest < Test::Unit::TestCase
  def test_sanitizer
    sanitizer = XssTerminate::TextSanitizer.new

    expected = {
      'a<b'      => 'a<b',
      'a<b<c'    => 'a<b<c',
      'a<<'      => 'a<<',
      'a<d>'     => 'a',
      'a<>'      => 'a<>',
      'a<<>'     => 'a<<>',
      'a<<>>'     => 'a<<>>',
      'a<<d>>'   => 'a<>',
      'a</b>'    => 'a',
      'a</b'     => 'a</b',
      'a>b'      => 'a>b',
      'a/b>'     => 'a/b>',
      'a</b>/c>' => 'a/c>',
      'a<b>c'    => 'ac',
      'a< b>'    => 'a< b>',
      'a<b >c'   => 'ac',
      'a<b >c<>' => 'ac<>',
      'a< b<b></b>>'   => 'a< b>',
      'a< b<b>c</b> >' => 'a< bc >',
      'a<0>'           => 'a<0>',
      '<script>alert("hi")</script>' => 'alert("hi")',
      '<a href="test">A&B</a>'       => 'A&B',
    }
    expected.each do |input, expected|
      assert_equal expected, sanitizer.sanitize(input)
    end
  end
end
