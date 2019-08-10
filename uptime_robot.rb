#!/usr/bin/env ruby


# <bitbar.title>UptimeRobot dashboard</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Sergey Pedan</bitbar.author>
# <bitbar.author.github>sergeypedan</bitbar.author.github>
# <bitbar.desc>Lists your UptimeRobot monitors with their statuses to help you instantly check uptime of your websites.</bitbar.desc>
# <bitbar.dependencies>Ruby 2+</bitbar.dependencies>
# <bitbar.image>https://raw.githubusercontent.com/sergeypedan/bitbar-uptime-robot-dashboard/master/screenshot.png</bitbar.image>
# <bitbar.abouturl>https://github.com/sergeypedan/bitbar-uptime-robot-dashboard</bitbar.abouturl>


require "json"
require "net/https"
require "uri"


module BitBar

  API_KEY_NAME  = "UPTIME_ROBOT_API_KEY".freeze
  API_ENDPOINT  = "https://api.uptimerobot.com/v2/getMonitors".freeze
  DASHBOARD_URL = "https://uptimerobot.com/dashboard"
  CONFIG_FILE   = "#{`echo $HOME`.chomp}/.config/bitbar.conf"

  COLOR_DOTS = {
    gray:   "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAXVBMVEUAAAAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmCynqnaAAAAHnRSTlMAAwYHCQoQEh0fNVBRX2N5fJG+wMfK3O3v8fP3+/37J2BkAAAATklEQVQIHQXBhQHCAADAsA53d1j+P5OkqoaqqmbHr/G8rGr1BuOmmjwB47L2AM51A/CrFwBDFwDf2gI41fAAfObV4gFe66qG3fV9P0yrPxEfCr3MVhkLAAAAAElFTkSuQmCC",
    green:  "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAXVBMVEUAAAAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmAnrmCynqnaAAAAHnRSTlMAAwYHCQoQEh0fNVBRX2N5fJG+wMfK3O3v8fP3+/37J2BkAAAATklEQVQIHQXBhQHCAADAsA53d1j+P5OkqoaqqmbHr/G8rGr1BuOmmjwB47L2AM51A/CrFwBDFwDf2gI41fAAfObV4gFe66qG3fV9P0yrPxEfCr3MVhkLAAAAAElFTkSuQmCC",
    orange: "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAXVBMVEUAAADAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvGu33lAAAAHnRSTlMAAwYHCQoQEh0fNVBRX2N5fJG+wMfK3O3v8fP3+/37J2BkAAAATklEQVQIHQXBhQHCAADAsA53d1j+P5OkqoaqqmbHr/G8rGr1BuOmmjwB47L2AM51A/CrFwBDFwDf2gI41fAAfObV4gFe66qG3fV9P0yrPxEfCr3MVhkLAAAAAElFTkSuQmCC",
    red:    "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAXVBMVEUAAADAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvAOSvGu33lAAAAHnRSTlMAAwYHCQoQEh0fNVBRX2N5fJG+wMfK3O3v8fP3+/37J2BkAAAATklEQVQIHQXBhQHCAADAsA53d1j+P5OkqoaqqmbHr/G8rGr1BuOmmjwB47L2AM51A/CrFwBDFwDf2gI41fAAfObV4gFe66qG3fV9P0yrPxEfCr3MVhkLAAAAAElFTkSuQmCC"
  }

  module Interface
    def self.write!(status_bar: "", content_lines: [], colophone: "")
      puts status_bar if status_bar.to_s != ""

      if content_lines.any?
        puts "---"
        content_lines.each do |line| puts line end
      end

      if colophone.to_s != ""
        puts "---"
        puts colophone
      end
    end
  end

  module Keys

    module_function

    def read_API_key
      config_file_contents = File.read(CONFIG_FILE)
      line_with_key = config_file_contents.lines.select { |line| line.include? API_KEY_NAME }.first
      extract_key_from_config_line(line_with_key)
    end

    def extract_key_from_config_line(line)
      line.to_s.sub(API_KEY_NAME, "").sub("=", "").sub(":", "").gsub("\"", "").gsub(/\s/, "")
    end
  end

  module_function

  def build_line(text, attributes = {})
    str_attributes = stringified_attributes(attributes)
    return text if str_attributes == ""
    [text, str_attributes].join(" | ")
  end

  def stringified_attributes(hash)
    return "" if hash.empty?
    return "" if hash.values.all? { |value| value.to_s == "" }
    return hash.map { |key, value| "#{key}=#{value}" }.join(" ")
  end

end


module NetAccess

  def self.get_response(api_key:, endpoint:)
    uri = URI.parse(endpoint)

    http             = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request["accept"]        = "application/json"
    request["cache-control"] = "no-cache"
    request["content-type"]  = "x-www-form-urlencoded"
    request.set_form_data({ api_key: api_key, format: "json", logs: 0 })

    response = http.request(request)

    return JSON.parse(response.body) rescue {}
  end

end


class UptimeReporter

  STATUSES = {
    0 => { text: "paused",      color: "white",  image: BitBar::COLOR_DOTS[:gray] },
    1 => { text: "not checked", color: "white",  image: BitBar::COLOR_DOTS[:gray] },
    2 => { text: "up",          color: "green",  image: BitBar::COLOR_DOTS[:green] },
    8 => { text: "seems down",  color: "yellow", image: BitBar::COLOR_DOTS[:orange] },
    9 => { text: "down",        color: "red",    image: BitBar::COLOR_DOTS[:red] }
  }.freeze


  def initialize(color_blind: false)
    @color_blind = color_blind
    @api_key = BitBar::Keys.read_API_key
  end


  def run!
    monitors = get_monitors
    write(monitors)
  end


  private

  # @returns Array, like: [3, 5]
  # for 3 live services out of 5
  def count_of_live_servers(monitors)
    monitors.count { |monitor| server_live? monitor }
  end


  def get_monitors
    uptime_response["monitors"] || []
  end


  # @returns String like "google.com — Up | href='http://google.com' color='green'"
  def monitor_text(monitor)
    details = STATUSES[ monitor["status"] ]
    text = if @color_blind
             [monitor["friendly_name"], " (", details[:text], ")"].join("")
           else
             monitor["friendly_name"]
           end

    BitBar.build_line(text, href: monitor["url"], image: details[:image])
  end


  # @returns boolean
  def server_live?(monitor)
    monitor["status"] <= 2
  end


  # @returns String
  def status_bar_text(monitors)
    "#{count_of_live_servers(monitors)} / #{monitors.size}"
  end


  def uptime_response
    NetAccess.get_response(api_key: @api_key, endpoint: BitBar::API_ENDPOINT)
  end


  def write(monitors)
    BitBar::Interface.write!(
      status_bar:    status_bar_text(monitors),
      content_lines: monitors.map { |monitor| monitor_text(monitor) },
      colophone:     BitBar.build_line("Open UptimeRobot", href: BitBar::DASHBOARD_URL)
    )
  end

end

UptimeReporter.new(color_blind: false).run!
