require 'net/ftp'
require 'fileutils'
require 'zip/zipfilesystem'

require_relative 'constants'

class Logs
  include Constants
  
  attr_accessor :ip, :port, :user, :password, :dir

  def initialize details
    @ip, @port, @user, @password, @dir = *details
  end

  def open_down
    @down = Net::FTP.new.tap do |conn|
     conn.connect(ip, port)
     conn.login(user, password)
     conn.passive = true
      conn.chdir dir + "/logs" if dir + "/logs"
    end
  end
  
  def open_up
    @up = Net::FTP.open(const["logs"]["ftp"]["ip"], const["logs"]["ftp"]["user"], const["logs"]["ftp"]["password"]).tap do |conn|
      conn.passive = true
      conn.chdir const["logs"]["ftp"]["dir"] if const["logs"]["ftp"]["dir"]
    end
  end
  
  def close conn
    conn.close if conn
  end
  
  def logs conn = @down
    conn.nlst.reject { |filename| !(filename =~ /.+\.log/) }
  end
  
  def update server
    logs.each do |filename|
      file = "#{ server }-#{ filename }"
      
      storage = "#{ const["logs"]["storage"] }#{ server }"
      
      # TODO: Does storage exist?
      FileUtils.mkdir_p storage if storage and not Dir.exists? storage

      # Download file
      @down.gettextfile filename, storage + filename  

      @up.puttextfile storage + filename, file 
      
      # Delete local files
      FileUtils.rm storage + filename 

      # Delete remote files
     # @down.delete filename if const["logs"]["delete"]["remote"]
    end
  end
  
  def purge
    logs(@down).each do |filename|
      if filename =~ /(.{1})(.{2})(.{2})(.{3})\.log/
        log, month, day, lognumber = $1, $2, $3, $4
        year = Time.now.year
        @down.delete filename if Time.mktime(year, month, day) + 86400 < Time.now
      end
    end
    logs(@up).each do |filename|
      if filename =~ /(.{1})(.{2})(.{2})(.{3})\.log/
        log, month, day, lognumber = $1, $2, $3, $4
        year = Time.now.year
        @up.delete filename if Time.mktime(year, month, day) + 1209600 < Time.now
      end
    end
  end
  
  def connect
    open_up
    open_down
  end
  
  def disconnect
    close @up
    close @down
  end
end
