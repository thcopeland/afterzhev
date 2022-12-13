def extract_item_sprites(fname, type, name)
    data = `convert #{fname} -alpha extract -define connected-components:verbose=true -connected-components 8 null:`
    component_lines = data.lines.select { |line| line =~ /srgb\(255,255,255\)/ }
    components = component_lines.map do |line|
        match = line.match(/^\s*(\d+):\s*(\d+)x(\d+)\+(\d+)\+(\d+)/)
        if match.nil?
            puts "Unexpected result from ImageMagick:"
            puts data.inspect
            exit 1
        end
        match[2..5].map(&:to_i)
    end

    components.sort_by! do |w, h, x, y|
        ((x+w/2) / 16) + ((y+h/2) / 16) * 16
    end

    names = {
        weapon: [
            "#{name}_walk_down_0",  "#{name}_walk_down_1",  "#{name}_walk_down_2",  "#{name}_walk_down_3",
            "#{name}_walk_right_0",  "#{name}_walk_right_1",  "#{name}_walk_right_2",  "#{name}_walk_right_3",
            "#{name}_idle_down",  "#{name}_idle_right",
            "#{name}_attack_down_0",  "#{name}_attack_down_1",  "#{name}_attack_down_2",  "#{name}_attack_down_3",
            "#{name}_attack_right_0",  "#{name}_attack_right_1",  "#{name}_attack_right_2",  "#{name}_attack_right_3"
        ],
        wearable: [
            "#{name}_walk_down_0",  "#{name}_walk_down_1",  "#{name}_walk_down_2",  "#{name}_walk_down_3",
            "#{name}_walk_right_0",  "#{name}_walk_right_1",  "#{name}_walk_right_2",  "#{name}_walk_right_3",
            "#{name}_walk_up_0",  "#{name}_walk_up_1",  "#{name}_walk_up_2",  "#{name}_walk_up_3",
            "#{name}_walk_left_0",  "#{name}_walk_left_1",  "#{name}_walk_left_2",  "#{name}_walk_left_3",
            "#{name}_idle_down",  "#{name}_idle_right",  "#{name}_idle_up",  "#{name}_idle_left",
        ]
    }

    if components.length != names[type].length
        puts "item2asm.rb: unexpected sprite count (expected #{names[type].length}, got #{components.length}). Possibly incorrect type #{type}?"
        exit 1
    end

    headers = []
    images = []

    components.each do |w, h, x, y|
        offset_x = (x % 16)
        offset_y = (y % 16)
        data = `convert #{fname} -crop #{w}x#{h}+#{x}+#{y} +repage -background magenta -alpha background -alpha remove -depth 8 rgb:-`
        pixels = data.unpack("C*").each_slice(3).map { |r, g, b| (b & 0xC0) | ((g >> 2) & 0x38) | ((r >> 5) & 0x07) }
        match = images.find { |w, h, img_pixels| img_pixels == pixels }

        if match.nil?
            images << [w, h, pixels]
            match = images.last
        end

        headers << [ offset_x, offset_y, w, h, images.index(match) ]
    end

    headers.each do |x, y, w, h, img_idx|
        puts "    item_animation_entry #{x}, #{y}, #{name}_sprite_#{img_idx}"
    end
    (20 - headers.length).times { puts "    empty_animation_entry" }

    puts

    images.each_with_index do |data, i|
        w, h, pixels = data
        puts "_#{name}_sprite_#{i}:"
        rows = pixels.each_slice(w).map { |slice| slice.map { |p| "0x"+p.to_s(16).rjust(2, "0") } }
        puts "    .db #{w}, #{h}"
        puts "    .db #{rows[0].join(", ")}, \\"
        puts rows[1..(h-2)].map { |row| "        #{row.join(", ")}, \\" }
        puts "        #{rows[h-1].join(", ")}#{(w*h).even? ? "" : ", PADDING" }"
    end
end

def usage_msg
    puts "Usage: ruby item2asm.rb [OPTIONS] FILE"
end

def help_msg
    usage_msg
    puts "Convert a PNG item spritesheet into assembly directives for an animated item table entry."
    puts "Sprites are assumed to be contained in the standard 16x16 layout."
    puts
    puts "  -p, --weapon             the item is a weapon (default)"
    puts "  -r, --wearable           the item is wearable"
    puts "  -n, --name NAME          the item's name (default `item')"
    puts "  -h, --help               display this help and exit"
end

fname = nil
type = :weapon
name = "item"

if ARGV.empty?
    usage_msg
    exit 1
end

i = 0
while i < ARGV.length
    arg = ARGV[i]
    if arg == "-p" || arg == "--weapon"
        type = :weapon
        i += 1
    elsif arg == "-r" || arg == "--wearable"
        type = :wearable
        i += 1
    elsif arg == "-n" || arg == "--name"
        name = ARGV[i+1]
        i += 2
    elsif arg == "-h" || arg == "--help"
        help_msg
        exit 0
    elsif arg.start_with? "-"
        puts "item2asm.rb: invalid argument `#{arg}'"
        usage_msg
        exit 1
    else
        fname = arg
        i += 1
    end
end

if fname.nil?
    puts "item2asm.rb: must provide an input file"
    exit 1
end

extract_item_sprites(fname, type, name)
