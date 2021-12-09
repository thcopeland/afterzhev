##
# png28bit is a utility to easily convert 12x12 PNG images to AFT images. AFT
# (AfterZhev sprite and tile format) is a 8-bit (BBGGGRRR) raw format. Magenta
# may be considered transparent. png2aft depends on ImageMagick to preprocess
# and decode the PNG file.
#

def fail(s)
  puts s
  exit
end

def check_args
  fail "Usage: ruby png2aft IN.png OUT.aft" if ARGV.size != 2
end

def check_exists(file)
  fail "png2aft: File #{file} not found" unless File.exists?(file)
end

def check_im
  `identify`
  `convert`
rescue Errno::ENOENT
  fail "png2aft: Unable to run ImageMagick"
end

def check_image(file)
  check = `identify #{file} 2> /dev/null`
  fail "png2aft: #{file} is not a PNG file" if check !~ /png/

  w, h = check.match(/(\d+)x(\d+)/)[1..2].map(&:to_i)
  fail "png2aft: Image must be 12x12" if w != 12 || h != 12
end

def convert_file(input, output)
  data = `convert #{input} -background magenta -alpha background -alpha remove rgb:-`
  pixels = data.unpack("C*").each_slice(3).to_a
  pixels_8bit = pixels.map { |r, g, b| (b & 0xC0) | ((g >> 2) & 0x38) | ((r >> 5) & 0x07) }

  # debugging:
  pixels_8bit.each_with_index do |p, i|
    print "vbuff[#{i%12 + (i/12)*120}] = 0x#{p.to_s(16)}; "
    puts if (i+1)%12 == 0
  end

  File.open(output, "w") do |f|
    f << pixels_8bit.pack("C*")
  end
end

check_args
check_exists(ARGV[0])
check_im
check_image(ARGV[0])
convert_file(ARGV[0], ARGV[1])
