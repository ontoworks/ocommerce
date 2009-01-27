require 'rubygems'
require 'RMagick'
require 'ftools'

def resize(file, format, dir)
  img = Magick::Image.read "#{dir}/#{file}"
  cols = img[0].columns
  rows = img[0].rows
  p "Procesando #{file}"
  thumb = img[0].scale(75, 75*rows/cols)
  thumb.write "#{dir}/#{file.split(".")[0].upcase}_thumb.jpg"
end

dir = ARGV[0] || "./"

files = `ls #{dir}`.split("\n")
files.each do |file|
  if file =~ /[A-Za-z0-9]+\.(jpg|png|gif)$/
    resize(file, $1, dir)
  end
end


