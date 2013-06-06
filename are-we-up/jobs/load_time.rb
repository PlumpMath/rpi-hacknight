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

last_time = 0
SCHEDULER.every '2s' do |j|
  st = Time.new.to_ms
  res = get_redirected(URI('http://spreadshirt.de/-C4407'))
  fi = Time.new.to_ms

  time = fi - st
  send_event('sprd.index.load', { current: time, last: last_time })
  last_time = time
end
