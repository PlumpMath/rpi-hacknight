require 'net/http'
require 'json'

SCHEDULER.every '2m', :first_in => 0 do
  uri = URI.parse(settings.jenkins_host)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  url  = '/jenkins/view/%s/api/json?tree=jobs[healthReport[iconUrl]]' % settings.jenkins_view

  request = Net::HTTP::Get.new(url)
  request.basic_auth(settings.user, settings.pw)
  response = http.request(request)
  jobs     = JSON.parse(response.body)['jobs']

  if jobs
    report = {
      '80plus' => 0,
      '60to79' => 0,
      '40to59' => 0,
      '20to39' => 0,
      '00to19' => 0
    }

    jobs.each { |job|
      next if not job['healthReport']
      next if not job['healthReport'][0]
      next if not job['healthReport'][0]['iconUrl']

      case job['healthReport'][0]['iconUrl']
      when 'health-80plus.png'
        report['80plus'] += 1
      when 'health-60to79.png'
        report['60to79'] += 1
      when 'health-40to59.png'
        report['40to59'] += 1
      when 'health-20to39.png'
        report['20to39'] += 1
      when 'health-00to19.png'
        report['00to19'] += 1
      end
    }

    send_event('jenkins_weather', { weather: report })
  end
end
