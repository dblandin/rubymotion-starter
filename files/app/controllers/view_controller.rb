class ViewController < UIViewController
  def viewDidLoad
    super

    view.backgroundColor = App::Colors['color_background_light']

    setup_constraints
  end

  def setup_constraints
    Motion::Layout.new do |layout|
      layout.view       view
      layout.subviews   'label' => label
      layout.horizontal '|[label]|'
      layout.vertical   '|[label]|'
    end
  end

  def label
    @label ||= UILabel.alloc.init.tap do |label|
      label.text = 'ViewController'
    end
  end
end
