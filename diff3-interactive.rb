#!/usr/bin/env ruby

MINE = ARGV[0]
BASE = ARGV[1]
YOURS = ARGV[2]

OUT = ARGV[3]

merged = `diff3 -m #{MINE} #{BASE} #{YOURS}`.force_encoding("UTF-8").gsub(/\r\n?/,"\n")

#HACK!
#Handle bug where files without newlines at the end confuse diff
merged_tac = merged.lines.to_a.reverse.join("")
merged_tac.sub!(/\A>>>>>>>[^\n]*\n(.*?)\n(.*?)=======\n<<<<<<<[^\n]*\n/m, "\\1\n")
merged_tac.sub!(/\A(.+?)>>>>>>>[^\n]*\n=======\n([^\n]*?)\n<<<<<<<[^\n]*\n/m, "\\2\n")
merged = merged_tac.lines.to_a.reverse.join("").sub(/\n\z/,'')

def get_choice_from_user()
	puts "Please choose:\n"
	puts "1: #{MINE}"
	puts "2: #{YOURS}"
	print "\n> "

	$stdin.gets.strip
end

merged.gsub! /^<<<<<<<[^\n]*\n(.*?)\n\|\|\|\|\|\|\|[^\n]*\n(.*?)\n=======[^\n]*\n(.*?)\n>>>>>>>[^\n]*/m do |match|
	mine = $1
	old = $2
	yours = $3

	puts "****************************** CONFLICT DETECTED! ******************************\n\n"

	puts "==============================================================================="
	puts "= 1: #{MINE + (" " * (72 - MINE.size))} ="
	puts "==============================================================================="
	puts mine + "\n\n"

	puts "==============================================================================="
	puts "= 2: #{YOURS + (" " * (72 - YOURS.size))} ="
	puts "==============================================================================="
	puts yours + "\n\n"

	selected = ""
	choice = get_choice_from_user

	while selected.empty? do
		case choice
		when "1"
			selected = mine
		when "2"
			selected = yours
		else
			choice = get_choice_from_user
		end
	end

	selected
end

File.open(OUT, 'w') {|f| f.write(merged) }
