module App; module Colors
  class << self
    def self.[](name)
      colors[name].to_color
    end

    def colors
      {}
    end
  end
end; end
