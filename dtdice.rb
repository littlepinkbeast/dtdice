# Dice roller for Dungeons: the Dragoning
# Basic invocation example: "dtdice 10 5", where the first number is how many to roll and the second is how many to keep
# Advanced invocation example: "dtdice 10 5 x t25 q"
# Option Flags
# a## - Add a flat bonus. ## will be added to the total of the roll.
# d - Double exploding dice. Each die that explodes gets two dice added instead of one.
# n - No explosions. Report the highest value possible without keeping explosions, unless there are more explosions than
# discarded dice
# q - Quiet mode. Only report the total, not the individual die rolls.
# t## - Target. Keep explosions only if necessary to reach ##, or if there is no other option. Supersedes n.
# v - Verbose. Print debugging information.
# x - Extra explosions. Dice explode on nines as well as tens.


avoid_explosions = false
quiet_mode = false
nines_explode = false
have_target = false
verbose = false
target_number = 0
kept_explosion = false
flat_bonus = 0
double_dice = false

r, k, *options = ARGV
rolled = r.to_i
kept = k.to_i

if (rolled == 0 || kept == 0) then
	puts "Invalid or zero entry for number of dice. Results will be incorrect."
end

# D:tD dice rules: The most you can roll is 10k10. Excess rolled dice convert into kept dice at 2 to 1.
# If you end up at less than ten kept dice and are at 11 rolled dice, the extra one is just lost.
# If kept is 10 or greater, any excess rolled or kept dice become 5 points of flat bonus.

while (rolled > 11 && kept < 10) do
	rolled -= 2
	kept += 1
end

if kept >= 10 then
	k_bonus = kept - 10
	kept = 10
	if rolled >= 10 then
		r_bonus = rolled - 10
		rolled = 10
	end
	flat_bonus += (k_bonus + r_bonus) * 5
end

# By the time we get here, we should have taken care of all situations in which rolled dice can be converted into some
# kind of other bonus to the roll, and so if there's still an extra rolled die it just vanishes.

if rolled > 10 then rolled = 10 end

# The core die-roller function. "nines" is boolean, and specifies whether nines explode.
# "double" is also boolean, and specifies if a second explosion should be added.
# For each die, returns the value of the die and whether or not that die exploded.

def explode(nines, double)
	dummy = (rand * 10).to_i + 1
	if double then
		if dummy == 10 || ((dummy == 9) && nines) then 
			dummy += explode(nines, double) + explode(nines, double)
		end
	else
		if dummy == 10 || ((dummy == 9) && nines) then 
			dummy += explode(nines, double)
		end
	end
	dummy
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
		if target_number == 0 then puts "Target number argument found, but evaluated to 0. Check your typing." end
	elsif o[0] == 'a' then
		flat_bonus = o[1..o.length - 1].to_i
		if flat_bonus == 0 then puts "Flat bonus argument found, but evaluated to 0. Check your typing." end
	elsif o[0] == 'v' then
		verbose = true
	elsif o[0] == 'd' then
		double_dice = true
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
	puts "Double explosions: " + double_dice.to_s
	puts "Try to reach target: " + have_target.to_s
	puts "Target number: " + target_number.to_s
	puts "Adding " + flat_bonus.to_s + " to the result."
end

if (kept > rolled) then kept = rolled end

prelim = Array.new
rolled.times do
	prelim.push explode(nines_explode, double_dice)
end
prelim.sort!.reverse!

full_value = 0
result = 0
#calculate the maximum value of the roll, including all explosions
0.upto(kept-1) do |x| 
	full_value += prelim[x]
	kept_explosion = (kept_explosion || (prelim[x] >= 10))
end
if (have_target || avoid_explosions) then
	# As far as I can tell, keeping more than one explosion doesn't make things worse, so if the target number can't
	# be reached without explosions, use the full value with all explosions.
	if (kept_explosion == true && prelim[kept * -1] < 10)then # make sure there's enough non-exploded dice to keep
		while prelim[0] >= 10 do
			prelim.push(prelim.shift)
		end
		kept_explosion = false
		0.upto(kept-1) do |x| 
			result += prelim[x]
			kept_explosion = (kept_explosion || (prelim[x] >= 10))
		end
		result += flat_bonus
		if result < target_number then
			result = full_value + flat_bonus
			kept_explosion = true
		end
	else
		result = full_value + flat_bonus
		kept_explosion = (prelim[0] >= 10)
	end
else #normal roll
	result = full_value + flat_bonus
end
if (quiet_mode == false) then
	if target_number > 0 then
		puts "Target number: " + target_number.to_s
	end
	prelim.each do |i|
		print i.to_s + " "
	end
	print "\n"
end
print result.to_s
if kept_explosion then 
	print " (Includes exploded dice.)" 
else
	print " (No explosions.)"
end
print "\n"