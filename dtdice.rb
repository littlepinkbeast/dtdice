# Dice roller for Dungeons: the Dragoning
# Basic invocation example: "dtdice 10 5", where the first number is how many to roll and the second is how many to keep
# Advanced invocation example: "dtdice 10 5 x t25 q"
# Option Flags
# a## - Add a flat bonus. ## will be added to the total of the roll.
# n - No explosions. Report the highest value possible without keeping explosions, unless there are more explosions than
# discarded dice
# q - Quiet mode. Only report the total, not the individual die rolls.
# t## - Target. Keep explosions only if necessary to reach ##, or if there is no other option.
# x - Extra explosions. Dice explode on nines as well as tens.
# v - Verbose. Print debugging information.

avoid_explosions = false
quiet_mode = false
nines_explode = false
have_target = false
verbose = false
target_number = 0
kept_explosion = false
flat_bonus = 0

r, k, *options = ARGV
rolled = r.to_i
kept = k.to_i

if (rolled == 0 || kept == 0) then
	puts "Invalid or zero entry for number of dice. Results will be incorrect."
end

def explode(nines)
	bang = false
	dummy = (rand * 10).to_i + 1
	if dummy == 10 || ((dummy == 9) && nines) then 
		bang = true
		dummy += explode(nines)[0]
	end
	return dummy, bang
end

options.each do |o|
	if o[0] == 'n' then
		avoid_explosions = true
	elsif o[0] == 'q' then
		quiet_mode = true
	elsif o[0] == 'x' then
		nines_explode = true
	elsif o[0] == 't' then
		have_target = true
		target_number = o[1..o.length - 1].to_i
	elsif o[0] == 'a' then
		flat_bonus = o[1..o.length - 1].to_i
	elsif o[0] == 'v' then
		verbose = true
	else
		puts "Invalid option:" + o.to_s
	end
end

if verbose then
	puts "Rolling " + rolled.to_s + " dice."
	puts "Keeping " + kept.to_s + " dice."
	puts "Avoid explosions: " + avoid_explosions.to_s
	puts "Quiet mode: " + quiet_mode.to_s
	puts "Nines explode: " + nines_explode.to_s
	puts "Try to reach target: " + have_target.to_s
	puts "Target number: " + target_number.to_s
	puts "Adding " + flat_bonus.to_s + " to the result."
end

if (kept > rolled) then kept = rolled end

prelim = Array.new
rolled.times do
	res, popped = explode(nines_explode)
	kept_explosion = (kept_explosion || popped)
	prelim.push res
end
prelim.sort!.reverse!
puts prelim.to_s unless quiet_mode
result = 0
0.upto(kept-1) { |x| result += prelim[x]}
result += flat_bonus
puts result.to_s + ": " + kept_explosion.to_s