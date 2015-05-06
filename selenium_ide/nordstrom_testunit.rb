require "json"
require "selenium-webdriver"
require "test/unit"

class NordstromTestunit < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://5.syndeca.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end
  
  def test_nordstrom_testunit
    @driver.get "http://5.syndeca.com/nordstrom/index.html?archive=true#catalog/jan-2015-move/page/1"
    assert !60.times{ break if (element_present?(:css, "img.syndeca-carousel-spread-hit") rescue false); sleep 1 }
    @driver.find_element(:css, "area[alt=\"Nike 'HSC' Dri-FIT Hooded Top\"]").click
    assert !60.times{ break if (element_present?(:css, "div.syn-product-info > h3") rescue false); sleep 1 }
    @driver.find_element(:xpath, "//a[contains(@href, '#close')]").click
    assert !60.times{ break unless (element_present?(:xpath, "//a[contains(@href, '#close')]") rescue true); sleep 1 }
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
