# encoding: UTF-8

require 'rubygems'
require 'test/unit'
require 'selenium-webdriver'

class SampleTest < Test::Unit::TestCase
  USERNAME = ENV['BS_USERNAME']
  BROWSERSTACK_ACCESS_KEY = ENV['BS_AUTHKEY']

  def setup
    if USERNAME.nil? || USERNAME == '' || BROWSERSTACK_ACCESS_KEY.nil? || BROWSERSTACK_ACCESS_KEY == ''
      puts "Please set ENV while running rake task: rake BS_USERNAME=XXX BS_AUTHKEY=YYY ..."
      exit
    end
    url = "http://#{USERNAME}:#{BROWSERSTACK_ACCESS_KEY}@hub.browserstack.com/wd/hub"
    capabilities = Selenium::WebDriver::Remote::Capabilities.new
    capabilities['os'] = ENV['BS_AUTOMATE_OS']
    capabilities['os_version'] = ENV['BS_AUTOMATE_OS_VERSION']
    capabilities['browser'] = ENV['SELENIUM_BROWSER']
    capabilities['browser_version'] = ENV['SELENIUM_VERSION']
    capabilities['browserstack.debug'] = true
    capabilities['resolution'] = '1280x1024'
    @driver = Selenium::WebDriver.for(:remote,
                                      :url => url,
                                      :desired_capabilities => capabilities)
  end

  def test_product_modal
    @driver.get "http://5.syndeca.com/nordstrom/index.html?archive=true#catalog/jan-2015-move/page/1"
    assert !60.times{ break if (element_present?(:css, "img.syndeca-carousel-spread-hit") rescue false); sleep 1 }

    #@driver.find_element(:css, "area[alt=\"Nike 'HSC' Dri-FIT Hooded Top\"]").click
    @driver.execute_script('document.querySelector("area[alt=\"Nike \'HSC\' Dri-FIT Hooded Top\"]").click()')
    assert !60.times{ break if (element_present?(:css, "div.syn-product-info > h3") rescue false); sleep 1 }

    #@driver.find_element(:xpath, "//a[contains(@href, '#close')]").click
    @driver.execute_script('document.querySelector(".syn-product-modal-close").click()')
    assert !60.times{ break unless (element_present?(:xpath, "//a[contains(@href, '#close')]") rescue true); sleep 1 }
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def teardown
    @driver.quit
  end
end
