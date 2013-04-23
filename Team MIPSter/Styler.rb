require 'fileutils'

def backup(file_name)
  FileUtils.cp(file_name, file_name + ".bak")
end

def longest_code(file_name)
  longest = 0

  File.readlines(file_name).each do |line|
    if line.include? '#' and not line.strip.start_with? '#'
      code = line[0..line.index('#') - 1]
      code.rstrip!

      if code.length > longest then longest = code.length
    end
  end

  return longest
end

def space_comments(file_name)
  longest = longest_code file_name

  File.readlines(file_name).each do |line|
    if line.include? '#'
      code = line[0..line.index('#') - 1]
      comment = line[line.index('#')..-1]

      puts code + ' ' * 5 + comment
    else
      puts line
    end
  end
end

space_comments ARGV[0]
