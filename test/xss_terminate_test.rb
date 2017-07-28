class XssTerminateTest < Test::Unit::TestCase
  def test_xss_terminate_inheritance
    e = Entry.new
    assert_equal :html, e.xss_terminate_options_for(:body)[:format]
    assert_equal :html, e.xss_terminate_options_for(:extended)[:format]

    c = ChildEntry.new
    assert_equal :text, c.xss_terminate_options_for(:body)[:format]
    assert_equal :html, c.xss_terminate_options_for(:extended)[:format]
  end

  def test_strip_tags_on_discovered_fields
    c = Comment.create!(:title => "<script>alert('xss in title')</script>",
                        :body => "<script>alert('xss in body')</script>")

    assert_equal "alert('xss in title')", c.title
    assert_equal "alert('xss in body')", c.body
  end

  def test_sanitized_on_assignment
    c = Comment.new
    c.title = "<script>alert('xss in title2')</script>"
    assert_equal "alert('xss in title2')", c.title

    c[:title] = "<script>alert('xss in title3')</script>"
    assert_equal "alert('xss in title3')", c.title
  end

  def test_conditional_sanitization_with_an_if_proc
    c = ChildEntry.new
    c.body_format = :text
    c.body = "<script>alert('xss in title2')</script>&<b"
    assert_equal "alert('xss in title2')&<b", c.body

    # xss_terminate_options are cached. So we clear it
    c.xss_terminate_options_clear
    c.body_format = :raw
    c.body = "<script>alert('xss in title3')</script>&<b"
    assert_equal "<script>alert('xss in title3')</script>&<b", c.body
    c.save!

    # Saving should have cleared the xss_terminate_options cache.
    c.body_format = :html
    c.body = "<script>alert('xss in title4')</script>&<b"
    assert_equal "alert('xss in title4')&amp;<b></b>", c.body
  end

  def test_sanitization_options
    c = ChildEntry.new

    c.with_xss_terminate_options(format: :html) do
      c.body = "<script>alert('xss in title4')</script>&b"
      assert_equal "alert('xss in title4')&amp;b", c.body
    end

    c.with_xss_terminate_options(format: :html, html_options: {tags: %w[script]}) do
      c.body = "<script>alert('xss in title4')</script>&b"
      assert_equal "<script>alert('xss in title4')</script>&amp;b", c.body
    end
  end

  def test_rails_sanitization_on_specified_fields
    e = Entry.create!(:title => "<script>alert('xss in title')</script>&me",
                      :body => "<script>alert('xss in body')</script>&me",
                      :extended => "<script>alert('xss in extended')</script>&me",
                      :person_id => 1)

    assert_equal :html, e.xss_terminate_options_for(:body)[:format]
    assert_equal :html, e.xss_terminate_options_for(:extended)[:format]

    # The default text sanitizer returns text
    assert_equal "alert('xss in title')&me", e.title

    # The html5lib_sanitizers return HTML
    assert_equal "alert('xss in body')&amp;me", e.body
    assert_equal "alert('xss in extended')&amp;me", e.extended
  end
  
  def test_excepting_specified_fields
    p = Person.create!(:name => "<strong>Mallory</strong>")
    
    assert_equal({ format: :raw }, p.xss_terminate_options_for(:name))
    
    assert_equal "<strong>Mallory</strong>", p.name
  end

  def test_do_not_save_invalid_models_after_sanitizing
    c = Comment.new(:title => "<br />")
    assert !c.save
    assert_not_nil c.errors[:title]
  end
  
  def test_valid_work_with_serialize_fields
    g = Group.new(:title => "XSS Terminate group", :description => 'desc', :members => [1,2,3])
    assert g.save
  end
  
  def test_valid_work_with_number_fields
    g = Group.new(:title => "XSS Terminate group", :description => 123456, :members => {:hash => 'rocket'})
    assert g.save
  end
end
