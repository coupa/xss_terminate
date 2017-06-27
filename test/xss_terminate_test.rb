class XssTerminateTest < Test::Unit::TestCase
  def test_xss_terminate_inheritance
    assert_equal :html, Entry.xss_terminate_options_for(:body)[:as]
    assert_equal :html, Entry.xss_terminate_options_for(:extended)[:as]

    assert_equal :text, ChildEntry.xss_terminate_options_for(:body)[:as]
    assert_equal :html, ChildEntry.xss_terminate_options_for(:extended)[:as]
  end

  def test_strip_tags_on_discovered_fields
    c = Comment.create!(:title => "<script>alert('xss in title')</script>",
                        :body => "<script>alert('xss in body')</script>")

    assert_equal "alert('xss in title')", c.title
    
    assert_equal "alert('xss in body')", c.body
  end
  
  def test_rails_sanitization_on_specified_fields
    e = Entry.create!(:title => "<script>alert('xss in title')</script>&me",
                      :body => "<script>alert('xss in body')</script>&me",
                      :extended => "<script>alert('xss in extended')</script>&me",
                      :person_id => 1)

    assert_equal :html, Entry.xss_terminate_options_for(:body)[:as]
    assert_equal :html, Entry.xss_terminate_options_for(:extended)[:as]

    # The default text sanitizer returns text
    assert_equal "alert('xss in title')&me", e.title

    # The html5lib_sanitizers return HTML
    assert_equal "alert('xss in body')&amp;me", e.body
    assert_equal "alert('xss in extended')&amp;me", e.extended
  end
  
  def test_excepting_specified_fields
    p = Person.create!(:name => "<strong>Mallory</strong>")
    
    assert_equal({}, Person.xss_terminate_options_for(:name))
    
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
