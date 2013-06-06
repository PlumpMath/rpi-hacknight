require "net/https"
require 'json'

jenkins_host = 'https://build.spreadomat.net'
jenkins_view = 'RampantTree'

SCHEDULER.every '2m', :first_in => 0 do
  uri = URI.parse(jenkins_host)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  url  = '/jenkins/view/%s/api/json?tree=jobs[name,color]' % jenkins_view

  request = Net::HTTP::Get.new(url)
  request.basic_auth(settings.user, settings.pw)
  response = http.request(request)
  jobs     = JSON.parse(response.body)['jobs']

  if jobs
    jobs.map! { |job|
      color = 'grey'

      case job['color']
      when 'blue', 'blue_anime'
        color = 'blue'
      when 'red', 'red_anime'
        color = 'red'
      end

      { name: job['name'], state: color }
    }

    jobs.sort_by { |job| job['name'] }

    send_event('jenkins_jobs', { jobs: jobs })
  end
end
