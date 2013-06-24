require 'net/http'
require 'json'

SCHEDULER.every '2m', :first_in => 0 do
  uri = URI.parse(settings.jenkins_host)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  url  = '/jenkins/view/%s/api/json?tree=jobs[color]' % settings.jenkins_view

  request = Net::HTTP::Get.new(url)
  request.basic_auth(settings.user, settings.pw)
  response = http.request(request)
  jobs     = JSON.parse(response.body)['jobs']

  if jobs
    blue = 0
    red = 0
    grey = 0

    jobs.each { |job|
      case job['color']
      when 'blue', 'blue_anime'
        blue += 1
      when 'red', 'red_anime'
        red += 1
      else
        grey += 1
      end
    }

    send_event('jenkins_jobstates', { blue: blue, red: red, grey: grey })
  end
end
