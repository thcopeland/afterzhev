def merge_worlds(fname_base, fname_branch)
    base_lines = File.readlines(fname_base)
    branch_lines = File.readlines(fname_branch)

    File.open("merged.asm", "w") do |f|
         i = 0
         j = 0
         # skip initial comments
         while i < base_lines.length && base_lines[i] =~ /(^;)|(^\s+$)/
             f << base_lines[i]
             i += 1
         end

         raise "expected sector table" if base_lines[i] !~ /sector_table/
         f << base_lines[i]
         i += 1

         while i < base_lines.length && j < branch_lines.length
             if (base_lines[i] =~ /(\d{3},?\s+){20}/ && branch_lines[j] =~ /(\d{3},?\s+){20}/) || (base_lines[i] =~ /^\.db SECTOR_/ && branch_lines[j] =~ /^\.db SECTOR_/)
                f << branch_lines[j]
            elsif base_lines[i] =~ /\.d[bw][^\\]+$/ && branch_lines[j] =~ /\.d[bw][^\\]+$/
                f << base_lines[i]
            elsif base_lines[i] == branch_lines[j]
                f << base_lines[i]
            elsif base_lines[i].match(/^; Sector \d+ (\".+\")/)&.values_at(1) == branch_lines[j].match(/^; Sector (\".+\")/)&.values_at(1)
                f << branch_lines[j]
            else
                raise "mismatch on lines #{i+1} and #{j+1}: '#{base_lines[i].strip}' vs '#{branch_lines[j].strip}'"
            end
            i += 1
            j += 1
         end

         while i < base_lines.length
             f << base_lines[i]
             i += 1
         end
    end
end

if ARGV[0] && ARGV[1]
    merge_worlds(ARGV[0], ARGV[1])
else
    puts "Usage: ruby mergeworlds.rb BASE BRANCH"
end
