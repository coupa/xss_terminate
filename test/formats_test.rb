class FormatsTest < Test::Unit::TestCase
  def test_sanitize
    %i[html raw text].each do |format|
      # Should not crash
      s = XssTerminate::Formats[format].sanitizer
      if format == :raw
        assert_nil s
      else
        assert_not_nil s
        assert_not_nil s.sanitize("test")
      end

      assert_not_nil XssTerminate::Formats[format].sanitize("test")
    end
  end
end
