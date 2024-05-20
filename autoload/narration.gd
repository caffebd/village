extends Node

var main_index :int = 0
var sub_index :int =0

var corner_index: int = 3

var mound_index: int = 4
var clearing_index:int = 4

var orb_index: int = 6

var all_narration = [
	["My dad was the only one who called me Saif instead of Saiful."],
	["My dad always liked to take me on long walks through the forest...", "but that day we went further than we had ever been before."],
	["I remembered feeling excited and wondering if he had something special planned."],
	["For a second I panicked when I lost sight of my dad."],
	["Dad always liked to teach me something when we went walking."],
	["I suddenly realised I lost the 10 Taka note my dad gave me...", "I had to find it, otherwise he would be really upset."],
	["While I was looking around, I saw something glowing...", "I wanted to show dad what I had found."]
]

func narrate():
	if main_index < all_narration.size():
		if sub_index < all_narration[main_index].size():
			GlobalSignals.emit_signal("show_narration", all_narration[main_index][sub_index])
			sub_index += 1
			print (" SUB main "+str(main_index)+" sub "+str(sub_index))
		else:
			main_index += 1
			sub_index = 0
			GlobalSignals.emit_signal("show_narration", all_narration[main_index][sub_index])
	else:
		GlobalSignals.emit_signal("show_narration", "NARATION COMPLETE")
		 
func hide_narration():
	if sub_index == all_narration[main_index].size():
		main_index += 1
		sub_index = 0
		print (" HN main "+str(main_index)+" sub "+str(sub_index))
	else:
		narrate()
		
