require 'net/ftp'
require 'fileutils'
require 'zip/zipfilesystem'

require_relative 'constants'

class STV
  include Constants
  
  attr_accessor :ip, :port, :user, :password, :dir

  def initialize details
    @ip, @port, @user, @password, @dir = *details
  end

  def open_down
    @down = Net::FTP.new.tap do |conn|
      conn.connect(ip,port) 
      conn.login(user,password)
      conn.passive = true
      conn.chdir dir if dir
      end
  end
  
  def open_up
    @up = Net::FTP.open(const["stv"]["ftp"]["ip"], const["stv"]["ftp"]["user"], const["stv"]["ftp"]["password"]).tap do |conn|
      conn.passive = true
      conn.chdir const["stv"]["ftp"]["dir"] if const["stv"]["ftp"]["dir"]
    end
  end
  
  def close conn
    conn.close if conn
  end
  
  def demos conn = @down
    conn.nlst.reject { |filename| !(filename =~ /.+\.dem/) && !(filename =~ /.+\.zip/) }
  end
  
  def update server
    demos.each do |filename|
      file = "#{ server }-#{ filename }"
      filezip = "#{ file }.zip"
      filetemp = "#{ file }.tmp"

      storage = "#{ const["stv"]["storage"] }"
      
      # TODO: Does storage exist?
      FileUtils.mkdir_p storage if storage and not Dir.exists? storage

      # Download file and zip it
      @down.getbinaryfile filename, storage + filename
      Zip::ZipFile.open(storage + filezip, Zip::ZipFile::CREATE) { |zipfile| zipfile.add(filename, storage + filename) } if filename =~ /.+\.dem/

      # Upload the file with a temp file extension and rename it after uploading
      @up.putbinaryfile storage + filezip, filezip if filename =~ /.+\.dem/
      @up.putbinaryfile storage + filename, file if filename =~ /.+\.zip/
#      @up.rename filetemp, filezip
      
      # Delete local files
      FileUtils.rm storage + filename
      FileUtils.rm storage + filezip if const["stv"]["delete"]["local"] and File.exists?(storage + filezip)
      FileUtils.rm storage + file if const["stv"]["delete"]["local"] and File.exists?(storage + file)

      # Delete remote files
      @down.delete filename if const["stv"]["delete"]["remote"]
    end
  end
  
  def purge
    demos(@up).each do |filename|
      if filename =~ /(.+?)-(.{4})(.{2})(.{2})-(.{2})(.{2})-(.+?)\.dem/
        server, year, month, day, hour, min, map = $1, $2, $3, $4, $5, $6, $7
        @up.delete filename if Time.mktime(year, month, day, hour, min) + 1209600 < Time.now
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
