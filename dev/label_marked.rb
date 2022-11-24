# simplifies labeling collision tiles

require "tmpdir"

def label_marked(img_fname)
  width, height = `identify -format '%wx%h' #{img_fname}`.split("x").map(&:to_i)
  marked = []

  Dir.mktmpdir do |working_dir|
    `convert #{img_fname} -crop 12x12 +repage #{working_dir}/tile-%d.png`

    (height/12).times do |row|
      (width/12).times do |col|
        idx = row*width/12 + col
        data = `convert #{working_dir}/tile-#{idx}.png -depth 8 rgba:-`
        marked << idx if data.unpack("C*").each_slice(4).any? { |r, g, b, a| a == 255 && r == 255 }
      end
    end
  end
  
  marked
end

puts label_marked(ARGV[0]).join(", ")
