require "curses"
include Curses

init_screen
curs_set(0)
start_color
noecho
cbreak
nonl
stdscr.keypad=(true)

continue = true

# Options array: Rolled dice, kept dice, flat bonus, target number, avoid explosions, nines explode, double explosions
# Target number has no effect unless avoid explosions is set

options = [["Roll   : ", 1], 
		   ["Keep   : ", 1], 
		   ["Bonus  : ", 0],
		   ["Target : ", 0], 
		   ["Avoid explosions  : ", false],
		   ["Explode on nines  : ", false],
		   ["Double explosions : ", false]]
		   
menu_ptr = 0 # which option is currently selected for alteration
result = 0
prelim = []
kept_explosion = false

# The core die-roller function. "nines" is boolean, and specifies whether nines explode.
# "double" is also boolean, and specifies if a second explosion should be added.

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

begin
	while continue do
		clear
		options.each_with_index do |opt, i|
			setpos(3 + i, 20)
			addstr(opt[0] + opt[1].to_s)
		end
		setpos(3 + menu_ptr, 17)
		addstr(">> ")
		setpos(options.size + 4, 20)
		addstr("Raw dice: #{prelim}")
		setpos(options.size + 5, 20)
		addstr("Result: #{result}")
		setpos(options.size + 6, 20)
		if kept_explosion then
			addstr("Includes explosions.")
		else
			addstr("No explosions.")
		end
		setpos(options.size + 10, 5)
		addstr("Up and down to select option, left and right to change value.")
		setpos(options.size + 11, 5)
		addstr("Press Space or Enter to roll dice. Press Escape to exit.")
		user_input = getch
		if user_input == 27 then #escape key
			continue = false
		elsif user_input == Key::LEFT
			if menu_ptr <= 3 then
				options[menu_ptr][1] -= 1
				if options[menu_ptr][1] < 0 then options[menu_ptr][1] = 40 end
			else
				if options[menu_ptr][1] == false then options[menu_ptr][1] = true else options[menu_ptr][1] = false end
			end
		elsif user_input == Key::RIGHT
			if menu_ptr <= 3 then
				options[menu_ptr][1] += 1
				if options[menu_ptr][1] > 40 then options[menu_ptr][1] = 0 end
			else
				if options[menu_ptr][1] == false then options[menu_ptr][1] = true else options[menu_ptr][1] = false end
			end		
		elsif user_input == Key::UP
			menu_ptr -= 1
			if menu_ptr < 0 then menu_ptr = options.size - 1 end
		elsif user_input == Key::DOWN
			menu_ptr += 1
			if menu_ptr >= options.size then menu_ptr = 0 end
		elsif user_input == ' ' || user_input == 13
# Biginneth heere much core logic
			rolled = options[0][1]
			kept = options[1][1]
			flat_bonus = options[2][1]
			target_number = options[3][1]
			have_target = options[4][1]
			nines_explode = options[5][1]
			double_dice = options[6][1]
			kept_explosion = false
			prelim = []
			result = 0
			full_value = 0
			
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
			
			if rolled > 10 then rolled = 10 end
			if (kept > rolled) then kept = rolled end

			rolled.times do
				prelim.push explode(nines_explode, double_dice)
			end
			prelim.sort!.reverse!

			#calculate the maximum value of the roll, including all explosions
			0.upto(kept-1) do |x| 
				full_value += prelim[x]
				kept_explosion = (kept_explosion || (prelim[x] >= 10))
			end
			if (have_target) then
				# As far as I can tell, keeping more than one explosion doesn't make things worse, so if the target number
				# can't be reached without explosions, use the full value with all explosions.
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
			
		end
	end
ensure
	close_screen
end