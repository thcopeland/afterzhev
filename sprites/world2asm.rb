# A fast utility to convert Tiled .world files and the associated .tmx and .tsx
# files into AVR assembly directives. There is some duplication between this and
# png2asm for performance.

require "json"
require "thread"
require "tmpdir"

WALKABLE_TILES = [0, 1, 2, 10, 11, 12, 13, 14, 15, 16, 19, 20, 21, 29, 30, 31, 32, 33, 34, 35, 38, 39, 40, 48, 49, 50, 51, 52, 69, 70, 71, 80, 88, 89, 102, 103, 104, 107, 112, 130, 131, 132, 142, 149, 150, 151, 168, 169, 170, 187, 188, 189, 206, 207, 208, 225, 226, 227, 228, 229, 230, 234, 235, 247, 252, 266, 271 ]

class TSXCompiler
  attr_reader :width, :height, :tile_width, :tile_height, :mapping

  def initialize(fname)
    @source = fname
    @mapping = []
    @width = nil
    @height = nil
    @tile_width = nil
    @tile_height = nil
  end

  def load_and_remap!
    tmx = File.read(@source)
    img_fname = extract_image_fname(tmx)
    @width, @height = extract_image_dimensions(tmx)
    @tile_width, @tile_height = extract_tile_dimensions(tmx)
    max_tile_count = width*height/tile_width/tile_height
    @mapping = Array.new(max_tile_count)

    Dir.mktmpdir do |working_dir|
      `convert #{img_fname} -crop #{tile_width}x#{tile_height} +repage #{working_dir}/tile-%d.png`

      semaphore = Mutex.new
      tiles = Array.new(max_tile_count)

      (height/tile_height).times do |row|
        (width/tile_width).times.map do |col|
          idx = row*width/tile_width + col
          Thread.new do
            data = convert_tile(idx, working_dir)
            semaphore.synchronize { tiles[idx] = data}
          end
        end.each(&:join)
      end

      File.open("./world2asm-tiles.asm", "w") do |f|
        label = 0
        WALKABLE_TILES.each do |idx|
          if tiles[idx]
            write_tile(tiles[idx], f)
            mapping[idx] = label
            tiles[idx] = nil
            label += 1
          end
        end

        tiles.each_with_index do |data, idx|
          if tiles[idx]
            write_tile(tiles[idx], f)
            mapping[idx] = label
            label += 1
          end
        end
      end
    end
  end

private

  def extract_image_dimensions(tmx)
    [ tmx.match(/<image.+width=\"(\d+)\"/)[1].to_i,
      tmx.match(/<image.+height=\"(\d+)\"/)[1].to_i ]
  end

  def extract_tile_dimensions(tmx)
    [ tmx.match(/<tileset.+tilewidth=\"(\d+)\"/)[1].to_i,
      tmx.match(/<tileset.+tileheight=\"(\d+)\"/)[1].to_i ]
  end

  def extract_image_fname(tmx)
    "#{File.dirname(@source)}/#{tmx.match(/<image.+source=\"([^\"]+)\"/)[1]}"
  end

  def convert_tile(idx, working_dir)
    pixels = `convert #{working_dir}/tile-#{idx}.png -channel B -depth 2 -channel RG -depth 3 -channel RGB -depth 8 rgba:-`.unpack("C*").each_slice(4).to_a
    any_blank = pixels.any? { |p| p[3] != 255 }

    if !any_blank
      pixels.map { |r, g, b| (b & 0xC0) | ((g >> 2) & 0x38) | ((r >> 5) & 0x07) }
    end
  end

  def write_tile(pixels, file)
    pixels.each_slice(@tile_width) do |row|
      file << ".db #{row.map { |x| "0x#{x.to_s(16).rjust(2, "0")}" }.join(", ")}\n"
    end
    file << "\n"
  end
end

class WorldCompiler
  attr_reader :tileset, :sector_width, :sector_height

  def initialize(fname)
    @source = fname
    @tileset = nil
  end

  def convert!
    world = File.read(@source)
    world_data = JSON.parse(world)
    maps = world_data["maps"]
    min_x, max_x = maps.map { |map| map["x"] }.minmax
    min_y, max_y = maps.map { |map| map["y"] }.minmax
    sample_sector = maps.first
    @sector_width = sample_sector["width"]
    @sector_height = sample_sector["height"]

    @tileset = TSXCompiler.new(discover_tsx_fname(sample_sector))
    tileset.load_and_remap!

    rows = (max_y - min_y)/sector_height + 1
    cols = (max_x - min_x)/sector_width + 1

    world_grid = rows.times.map { Array.new(cols) }

    maps.each do |map|
      row = (map["y"] - min_y)/sector_height
      col = (map["x"] - min_x)/sector_width
      world_grid[row][col] = load_tmx(map, 0)
    end

    # relabel
    label = 0
    rows.times do |row|
      cols.times do |col|
        sector = world_grid[row][col]
        if sector
          sector[:label] = label
          label += 1
        end
      end
    end

    File.open("world2asm-world.asm", "w") do |f|
      rows.times do |row|
        cols.times do |col|
          sector = world_grid[row][col]

          if sector
            left = col > 0 ? world_grid[row][col-1] : nil
            right = world_grid[row]&.at(col+1)
            up = row > 0 ? world_grid[row-1][col] : nil
            down = world_grid[row+1]&.at(col)

            write_tmx(sector, down, right, up, left, f)
          end
        end
      end
    end
  end

private

  def discover_tsx_fname(sample_sector)
    sample_tmx_fname = "#{File.dirname(@source)}/#{sample_sector["fileName"]}"
    sample_tmx = File.read(sample_tmx_fname)
    tsx_basename = sample_tmx.match(/<tileset.+source=['\"]([^'\"]+)['\"]/)[1]
    "#{File.dirname(sample_tmx_fname)}/#{tsx_basename}"
  end

  def load_tmx(data, label)
    fname = "#{File.dirname(@source)}/#{data["fileName"]}"
    tmx = File.read(fname)
    tiles = tmx.match(/<data.+>\n([\d\n,]+)/)[1].split(/[ \n,]+/).map { |i| i.to_i - 1 }
    {
      label: label,
      name: File.basename(fname).sub(/\.tmx$/, ""),
      tiles: tiles
    }
  end

  def write_tmx(sector, down, right, up, left, file)
    down ||= sector
    right ||= sector
    up ||= sector
    left ||= sector

    file << "; Sector #{sector[:label]} \"#{sector[:name]}\"\n"

    sector[:tiles].each_slice(sector_width/tileset.tile_width).with_index do |tiles, y|
      file << (y.zero? ? ".db " : "    ")                         \
           << tiles.map { |t| tileset.mapping[t].to_s.rjust(3, "0") }.join(", ")   \
           << (y < sector_height/tileset.tile_height-1 ? ", \\\n" : "\n")
    end

    file << ".db #{down[:label]}, #{right[:label]}, #{up[:label]}, #{left[:label]}\n"       \
         << ".db NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC, NO_NPC\n"          \
         << ".db NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0, NO_ITEM, 0, 0, 0\n"  \
         << ".db 0, 0, 0, 0\n"                                                              \
         << ".db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n"              \
         << ".dw NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER, NO_HANDLER\n"              \
         << "\n"
  end
end

def fail(msg)
  puts "world2asm: #{msg}"
  exit 1
end

def usage
  puts "Usage: ruby world2asm.rb FILE.world"
end

def check_exists(file)
  fail "world2asm: File #{file} not found" unless File.exists?(file)
end

def check_im
  `convert`
rescue Errno::ENOENT
  fail "world2asm: Unable to run ImageMagick"
end

if ARGV.length < 1
  usage
else
  check_exists ARGV.first
  check_im
  WorldCompiler.new(ARGV.first).convert!
end
