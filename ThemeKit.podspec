Pod::Spec.new do |s|
  s.name         = 'ThemeKit'
  s.version      = '1.0.0'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = 'A macOS Theming Framework'
  s.homepage     = 'https://github.com/luckymarmot/ThemeKit'
  s.screenshots  = 'https://raw.githubusercontent.com/luckymarmot/ThemeKit/master/Imgs/ThemeKit.gif'
  s.author       = { 'Paw Inc.' => 'https://paw.cloud' }
  s.source       = { :git => 'https://github.com/luckymarmot/ThemeKit.git', :tag => s.version }
  s.documentation_url = 'http://themekit.nunogrilo.com'

  s.platform     = :osx, '10.10'
  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end