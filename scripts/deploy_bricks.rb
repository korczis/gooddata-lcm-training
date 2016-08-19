# encoding: utf-8

require 'gooddata'

require_relative '../config'

DEFAULT_CRON = '0 0 * * *'

GoodData.with_connection($CONFIG[:username], $CONFIG[:password], :server => $CONFIG[:server], :verify_ssl => false) do |client|
  project = client.projects('sfxb3hrmmq6znow88r2qel06jw4qtvf4')
  puts JSON.pretty_generate(project.json)

  path = '${PUBLIC_APPSTORE}:branch/tma:/apps/provisioning_brick'

  process = project.deploy_process(path, name: 'Provisioning Brick')
  puts JSON.pretty_generate(process.json)

  options = {
    params: {
      organization: $CONFIG[:domain],
      CLIENT_GDC_PROTOCOL: 'https',
      CLIENT_GDC_HOSTNAME: $CONFIG[:hostname],
      ads_client: {
        username: $CONFIG[:ads][:username],
        password: $CONFIG[:ads][:password],
        ads_id: $CONFIG[:ads][:id]
      },
      input_source: {
        type: 'ads',
        query: $CONFIG[:ads][:query]
      },
      technical_user: [
        $CONFIG[:username]
      ],
      user_for_deployment: {
        login: $CONFIG[:username],
        password: $CONFIG[:password],
        server: $CONFIG[:server],
        verify_ssl: false
      },
      GDC_USERNAME: $CONFIG[:username]
    },
    hidden_params: {
      GDC_PASSWORD: $CONFIG[:password],
      additional_hidden_params: {
        GD_ADS_PASSWORD: $CONFIG[:ads][:password]
      }
    }
  }

  #  process.create_schedule(DEFAULT_CRON, 'main.rb', options)
  schedule = process.create_schedule(DEFAULT_CRON, 'main.rb', options)
  puts JSON.pretty_generate(schedule.json)
  schedule.disable!
end
