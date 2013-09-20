class AppDelegate
  attr_reader :window
  def application(application, didFinishLaunchingWithOptions: launch_options)
    return true if test_build?

    true
  end

  def dev_build?
    RUBYMOTION_ENV == 'development'
  end

  def test_build?
    RUBYMOTION_ENV == 'test'
  end

  def production_build?
    RUBYMOTION_ENV == 'release'
  end

  def testflight_build?
    !!App::ENV['DEPLOY']
  end
end
