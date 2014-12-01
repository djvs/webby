#!/usr/bin/ruby

require 'Qt'
require 'qtwebkit'
require 'yaml'

DEFAULTURL = "http://www.protopage.com"
myuser = `whoami`.strip
home = "/home/#{myuser}/.webby/"
`mkdir #{home}` if !Dir.exists?(home)

configf = "#{home}config"
bookmarkf = "#{home}bookmarks"
css = "#{home}css"
`touch #{configf}`
`touch #{bookmarkf}`
Config = YAML.load_file(configf)
Bookmarks = YAML.load_file(bookmarkf)
puts Bookmarks.inspect
Css = File.read(css)


class QtApp < Qt::Widget
  slots 'changeaddr(addr)', :bookmark

  def initialize
    super
    
    setWindowTitle "webby loading..."
    
    init_ui
    
    resize 640, 480
    move 20, 20

    show

    setStyleSheet(Css)

    Qt::Shortcut.new(Qt::KeySequence.new(Qt::CTRL.to_i + Qt::Key_Q.to_i), self, SLOT('close()'))
    Qt::Shortcut.new(Qt::KeySequence.new(Qt::CTRL.to_i + Qt::Key_B.to_i), self, SLOT('bookmark()'))
  end

  def bookmark
    puts @addressbar.text
  end
  
  def changeaddr(url)
    url = "http://#{url}" if !url.include?("://")
    @webview.load(Qt::Url.new(url))
  end
  
  def init_ui
    # layout
    vbox = Qt::VBoxLayout.new self
    bbox = Qt::HBoxLayout.new 

    @bookmarkbar = Qt::ToolBar.new
    Bookmarks.each do |k,v|
      bbutton = Qt::PushButton.new(k)
      connect(bbutton,SIGNAL('released()')){|x| changeaddr(v)}
      @bookmarkbar.addWidget bbutton
    end
    @addressbar = Qt::LineEdit.new DEFAULTURL, self
    @addressbar.setStyleSheet('background-color:white;color:black;')

    @webview = Qt::WebView.new do
      self.load Qt::Url.new(DEFAULTURL)
      show
    end

    vbox.addWidget @addressbar
    vbox.addWidget @bookmarkbar
    bbox.addWidget @webview
    vbox.addLayout bbox

    # qt settings
    @webview.settings.setAttribute(Qt::WebSettings::DeveloperExtrasEnabled, true)
    @webview.settings.setAttribute(Qt::WebSettings::LocalStorageEnabled, true)

    # map actions
    connect(@addressbar, SIGNAL(:returnPressed)) { |x| changeaddr(@addressbar.text) }
    connect(@webview, SIGNAL('titleChanged(QString)')) { |x| setWindowTitle("w> #{x}") }
    connect(@webview, SIGNAL('urlChanged(QUrl)')) { |x| @addressbar.text = x.toString }
  end
end

app = Qt::Application.new ARGV do 
    @app = QtApp.new
end
app.exec

