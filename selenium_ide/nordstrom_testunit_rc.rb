require "test/unit"
require "rubygems"
require "selenium/client"

class NordstromTestunitRc < Test::Unit::TestCase

  def setup
    @verification_errors = []
    @selenium = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*chrome",
      :url => "http://5.syndeca.com/",
      :timeout_in_second => 60

    @selenium.start_new_browser_session
  end
  
  def teardown
    @selenium.close_current_browser_session
    assert_equal [], @verification_errors
  end
  
  def test_nordstrom_testunit_rc
    @selenium.open "http://5.syndeca.com/nordstrom/index.html?archive=true#catalog/jan-2015-move/page/1"
    assert !60.times{ break if (@selenium.is_element_present("css=img.syndeca-carousel-spread-hit") rescue false); sleep 1 }
    @selenium.click "css=area[alt=\"Nike 'HSC' Dri-FIT Hooded Top\"]"
    assert !60.times{ break if (@selenium.is_element_present("css=div.syn-product-info > h3") rescue false); sleep 1 }
    @selenium.click "//a[contains(@href, '#close')]"
    assert !60.times{ break unless (@selenium.is_element_present("//a[contains(@href, '#close')]") rescue true); sleep 1 }
  end
end
