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

class BookmarkW < Qt::Widget
  def initialize
    super
    
    setWindowTitle "new bookmark"
    
    init_ui
    
    resize 200,160

    show
  end
  def init_ui
    vbox = Qt::VBoxLayout.new self

  end
end

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
    @bookmarkw = BookmarkW.new 
  end

  def savebookmark
    k = @webview.title.to_s
    v = @addressbar.text
    Bookmarks[k] = v
    addbookmarkb(k,v)
    puts Bookmarks.to_yaml
  end
  
  def changeaddr(url)
    url = "http://#{url}" if !url.include?("://")
    @webview.load(Qt::Url.new(url))
  end
  
  def addbookmarkb(k,v)
      puts "adding bookmark #{k} #{v}"
      bbutton = Qt::PushButton.new(k)
      connect(bbutton,SIGNAL('released()')){|x| changeaddr(v)}
      bbutton.setStyleSheet('background-color:white;color:black;margin:0px;padding:3px;')
      @bookmarkbar.addWidget bbutton
  end

  def init_ui
    # layout
    vbox = Qt::VBoxLayout.new self
    bbox = Qt::HBoxLayout.new 

    @bookmarkbar = Qt::ToolBar.new
    Bookmarks.each do |k,v|
     addbookmarkb(k,v)
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

