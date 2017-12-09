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
		addstr("Press Enter to roll dice. Press Escape to exit.")
		user_input = getch
		if user_input == 27 then #escape key
			continue = false
		elsif user_input == Key::LEFT
			if menu_ptr <= 3 then
				options[menu_ptr][1] -= 1
				if options[menu_ptr][1] < 0 then options[menu_ptr][1] = 20 end
			else
				if options[menu_ptr][1] == false then options[menu_ptr][1] = true else options[menu_ptr][1] = false end
			end
		elsif user_input == Key::RIGHT
			if menu_ptr <= 3 then
				options[menu_ptr][1] += 1
				if options[menu_ptr][1] > 20 then options[menu_ptr][1] = 0 end
			else
				if options[menu_ptr][1] == false then options[menu_ptr][1] = true else options[menu_ptr][1] = false end
			end		
		elsif user_input == Key::UP
			menu_ptr -= 1
			if menu_ptr < 0 then menu_ptr = options.size - 1 end
		elsif user_input == Key::DOWN
			menu_ptr += 1
			if menu_ptr >= options.size then menu_ptr = 0 end
		elsif user_input == Key::ENTER
		
		end
	end
ensure
	close_screen
end