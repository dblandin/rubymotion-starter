module App; module ENV
  class << self
    def [](key)
      variables["ENV_#{key}"]
    end

    def variables
      @variables ||= info_dictionary.select { |key, value| key.start_with? 'ENV_' }
    end

    def info_dictionary
      @info_dictionary ||= NSBundle.mainBundle.infoDictionary
    end
  end
end; end
