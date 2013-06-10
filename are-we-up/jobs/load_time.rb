require 'net/http'

def get_redirected(uri)
  res = Net::HTTP.get_response(uri)

  case res
  when Net::HTTPSuccess then
    res
  when Net::HTTPRedirection then
    loc = res['location']
    get_redirected(URI(loc))
  else
    "oops"
  end
end

class Time
  def to_ms
    (self.to_f * 1000).to_i
  end
end

class TimedRequest
  @@req_times = {}

  def self.timed(name, &block)
    st = Time.new.to_ms
    time = block.call
    fi = Time.new.to_ms
    time = if time.is_a? Numeric then time else fi - st end
    send_event(name, { current: time, last: @@req_times[name] || 0 })
    @@req_times[name] = time
  end

  def self.get(name, url)
    timed(name) { get_redirected(URI(url)) }
  end

  def self.browse(name, url)
    timed(name) { `phantomjs scripts/load.js #{url}`; nil }
  end
end

class Dict
  @@dict = File.read('/usr/share/dict/words').lines.map {|l| l[0..-2]}

  def self.random
    @@dict[rand() * (@@dict.length - 1)]
  end
end

SCHEDULER.every '10s' do |j|
  TimedRequest.browse('sprd.index.load', 'http://spreadshirt.de')
end

SCHEDULER.every '10s' do
  TimedRequest.browse('sprd.list.load', 'http://spreadshirt.de/-C4407')
end

SCHEDULER.every '10s' do
  TimedRequest.get('sprd.api.search', "http://api.spreadshirt.net/api/v1/shops/205909/articles?query=#{Dict.random}")
end
