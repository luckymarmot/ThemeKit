Pod::Spec.new do |s|
  s.name         = 'macOSThemeKit'
  s.version      = '1.4.0'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = 'macOS Theming Framework'
  s.homepage     = 'https://github.com/luckymarmot/ThemeKit'
  s.screenshots  = 'https://github.com/luckymarmot/ThemeKit/raw/master/Imgs/ThemeKit.gif'
  s.authors      = { 'Paw' => 'https://paw.cloud', 
                     'Nuno Grilo' => 'http://nunogrilo.com' }
  s.source       = { :git => 'https://github.com/luckymarmot/ThemeKit.git', 
                     :tag => s.version }
  s.documentation_url = 'http://themekit.nunogrilo.com'

  s.platform     = :osx, '10.10'
  s.requires_arc = true
  s.swift_version = '5.4.1'

  s.source_files = 'Sources/**/*.swift'
end
