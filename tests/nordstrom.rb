require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "Nordstrom" do

  USERNAME = ENV['BS_USERNAME']
  BROWSERSTACK_ACCESS_KEY = ENV['BS_AUTHKEY']
  # if something takes longer than 10 seconds, we should fail
  IMPLICIT_WAIT = 10

  before(:each) do
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
    @driver.manage.timeouts.implicit_wait = IMPLICIT_WAIT
    @driver.get "http://5.syndeca.com/nordstrom/index.html?archive=true#catalog/jan-2015-move/page/1"
  end

  after(:each) do
    @driver.quit
  end

  it "should load the first page" do
    expect(element_present?(:css, "img.syndeca-carousel-spread-hit")).to be true
  end

  it "should load a product modal and close it" do
    expect(element_present?(:css, 'area[alt="Nike \'HSC\' Dri-FIT Hooded Top"]')).to be true

    # open modal
    @driver.execute_script('document.querySelector("area[alt=\"Nike \'HSC\' Dri-FIT Hooded Top\"]").click()')
    expect(element_present?(:css, "div.syn-product-info > h3")).to be true

    # close
    @driver.find_element(:xpath, "//a[contains(@href, '#close')]").click
    expect(element_not_present?(:css, "div.syn-product-info > h3")).to be true
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def element_not_present?(how, what)
    # we want selenium to return false asap on each try by reducing wait to 1 sec
    @driver.manage.timeouts.implicit_wait = 1
    !10.times{ break unless @driver.find_element(how, what)}
    false
  rescue Selenium::WebDriver::Error::NoSuchElementError
    # set timeout back to normal once element gone
    @driver.manage.timeouts.implicit_wait = IMPLICIT_WAIT
    true
  end

end
