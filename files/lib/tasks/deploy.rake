desc 'Deploy to TestFlight/Crittercism'
task :deploy do
  App.config_without_setup.deploy_mode = true

  [Rake::Task['deploy:testflight'], Rake::Task['deploy:crittercism'].each do |task|
    task.invoke

    raise "#{task} failed!" if $?.exitstatus.nonzero?
  end
end

namespace 'deploy' do
  desc 'Submit archive to TestFlight'
  task :prepare do
    Rake::Task['archive'].invoke

    # An archived version of the .dSYM bundle is needed.
    app_dsym = App.config.app_bundle('iPhoneOS').sub(/\.app$/, '.dSYM')
    app_dsym_zip = app_dsym + '.zip'

    if !File.exist?(app_dsym_zip) or File.mtime(app_dsym) > File.mtime(app_dsym_zip)
      Dir.chdir(File.dirname(app_dsym)) do
        sh "/usr/bin/zip -q -r '#{File.basename(app_dsym)}.zip' '#{File.basename(app_dsym)}'"
      end
    end
  end

  desc 'Submit archive to TestFlight'
  task testflight: [:prepare] do
    testflight  = App.config.testflight

    App.fail 'A value for app.testflight.api_token is mandatory' unless testflight.api_token
    App.fail 'A value for app.testflight.team_token is mandatory' unless testflight.team_token

    App.info 'Deploying to TestFlight...'

    distribution_lists = (testflight.distribution_lists ? testflight.distribution_lists.join(',') : nil)
    notes = ENV['notes']

    App.fail %q(Submission notes must be provided via the `notes` environment variable.
    Example: rake testflight notes='w00t') unless notes

    app_dsym_zip = "#{App.config.app_bundle('iPhoneOS').sub(/\.app$/, '.dSYM')}.zip"

    curl = '/usr/bin/curl http://testflightapp.com/api/builds.json'\
           "-F file=@\'#{App.config.archive}'"\
           "-F dsym=@'#{app_dsym_zip}'"\
           "-F api_token='#{testflight.api_token}'"\
           "-F team_token='#{testflight.team_token}'"\
           "-F notes='#{notes}'"\
           "-F notify=#{testflight.notify ? 'True' : 'False'}"

    curl << " -F distribution_lists='#{distribution_lists}'" if distribution_lists

    App.info 'Run', curl
    sh curl
  end

  desc 'Submit .dSYM to Crittercism'
  task crittercism: [:prepare] do
    crittercism = App.config.crittercism

    App.fail 'A value for app.crittercism.app_id is mandatory'  unless crittercism.app_id
    App.fail 'A value for app.crittercism.api_key is mandatory' unless crittercism.api_key

    App.info 'Sending .dSYM to Crittercism...'

    endpoint_url = "https://api.crittercism.com/api_beta/dsym/#{crittercism.app_id}"

    curl = "/usr/bin/curl #{endpoint_url}"\
           '--write-out %{http_code} --silent --output /dev/null'\
           "-F dsym=@'#{app_dsym_zip}'"\
           "-F key='#{crittercism.api_key}'"

    App.info 'Run', curl
    sh curl
  end
end
