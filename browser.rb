#!/usr/bin/ruby

# ZetCode Ruby Qt tutorial
#
# In this program, we use box layouts
# to position two buttons in the
# bottom right corner of the window.
#
# author: Jan Bodnar
# website: www.zetcode.com
# last modified: September 2012

require 'Qt'
require 'qtwebkit'

DEFAULTURL = "http://www.startpage.a-revolt.org/index.php"

class QtApp < Qt::Widget
    slots 'changeaddr(addr)'

    def initialize
        super
        
        setWindowTitle "webby loading..."
        
        init_ui
        
        resize 640, 480
        move 20, 20

        show
        setStyleSheet('background-color:#333 !important;color:white;')
    end
    
    def changeaddr(url)
        url = "http://#{url}" if !url.include?("://")
        @webview.load(Qt::Url.new(url))
        puts "loading #{url}..."
    end
    
    def init_ui
        vbox = Qt::VBoxLayout.new self

        @addressbar = Qt::LineEdit.new DEFAULTURL, self
        @addressbar.setStyleSheet('background-color:white;color:black;')

        @webview = Qt::WebView.new do
            self.load Qt::Url.new(DEFAULTURL)
            show
        end
        @webview.settings.setAttribute(Qt::WebSettings::DeveloperExtrasEnabled, true)
        @webview.settings.setAttribute(Qt::WebSettings::LocalStorageEnabled, true)

        vbox.addWidget @addressbar
        vbox.addWidget @webview

        connect(@addressbar, SIGNAL(:returnPressed)) { |x| changeaddr(@addressbar.text) }
        connect(@webview, SIGNAL('titleChanged(QString)')) { |x| setWindowTitle("w> #{x}") }
    end
       

end

app = Qt::Application.new ARGV
QtApp.new
app.exec

