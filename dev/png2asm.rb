# png2asm is a utility to easily convert PNG images to assembly .DB directives.
# Each pixel is stored as a 8-bit (BBGGGRRR) value. Transparent values will
# become magenta.

def fail(s)
  puts s
  exit
end

def check_exists(file)
  fail "png2asm: File #{file} not found" unless File.exists?(file)
end

def check_im
  `identify`
  `convert`
rescue Errno::ENOENT
  fail "png2asm: Unable to run ImageMagick"
end

def check_image(file)
  check = `identify #{file} 2> /dev/null`
  fail "png2asm: #{file} is not a PNG file" if check !~ /png/
end

def convert_file(input, output)
  data = `convert #{input} -background magenta -alpha background -alpha remove -channel B -depth 2 -channel RGB -depth 3 -depth 8 rgb:-`
  pixels = data.unpack("C*").each_slice(3).to_a
  pixels_8bit = pixels.map { |r, g, b| (b & 0xC0) | ((g >> 2) & 0x38) | ((r >> 5) & 0x07) }
  ascii = '#WXx~-,. '.chars
  width = `identify -format %w #{input}`.to_i
  width += 1 if width.odd?

  File.open(output, "w") do |f|
    pixels_8bit.each_slice(width) do |data|
      f << ".db #{data.map { |x| "0x#{x.to_s(16).rjust(2, "0")}" }.join(", ")}\t; "
      data.each do |x|
        f << (x == 0xc7 ? " " : ascii[(((x>>6)&3)+((x>>3)&7)+(x&7))*(ascii.length-1)/17])*2
      end
      f << "\n"
    end
    f << "\n"
  end
end

check_im
ARGV.each do |f|
  check_exists(f)
  check_image(f)
  convert_file(f, f.sub(/(\.png)?$/, ".asm"))
end
