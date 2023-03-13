require "open3"

symbols = `grep -ohE '^[a-zA-Z0-9][a-zA-Z0-9_]+:' src/*.asm`.lines.map { |sym| sym.delete(":\n") }
File.open("tmp.asm", "w") do |f|
    f << ".include \"main.asm\"\n"
    symbols.each do |sym|
        f << ".message \"#{sym}\", 2*#{sym}\n"
    end
end

out_stdout, out_stderr, status = Open3.capture3("avra -D DEV -D TARGET=0 -I src -I src/data -o /dev/null -e /dev/null -d /dev/null tmp.asm")
lines = out_stderr.lines.select {|line| line =~ /^tmp.asm/}
symbols = lines.map do |line|
    label, addr = line.match(/^.+: ([a-z0-9A-Z_]+)(0x[a-f0-9A-F]+)/)[1..3]
    [ label, addr.to_i(16) ]
end.sort_by(&:last).reject {|label, addr| addr > 2**15}
labels = symbols.map(&:first)
addrs = symbols.map(&:last)
puts "char *labels[] = {#{labels.map(&:inspect).join(", ")}};"
puts "int addrs[] = {#{addrs.join(", ")}};"
