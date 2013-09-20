class TestFlightConfig
  attr_accessor :api_token, :team_token, :app_token, :distribution_lists, :notify
end

class CrittercismConfig
  attr_accessor :app_id, :api_key
end

module Motion; module Project; class Config
  attr_accessor :deploy_mode

  variable :testflight, :crittercism

  def testflight
    yield testflight_config if block_given? && deploy?

    testflight_config
  end

  def crittercism
    yield crittercism_config if block_given? && deploy?

    crittercism_config
  end

  def testflight_config
    @testflight_config ||= TestFlightConfig.new
  end

  def crittercism_config
    @crittercism_config ||= CrittercismConfig.new
  end

  def deploy?
    !!@deploy_mode
  end
end; end; end

