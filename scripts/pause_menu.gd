extends Control



#unpause the game
func _on_continue_pressed() -> void:
	get_tree().paused = false

	
	get_parent().visible = false #Hide the menu

	#Re-capture the mouse cursor so you can roll the ball again
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_options_pressed() -> void:
	
	$"..".hide()
	$"../../optionscanvas".show()
	
	
	
	pass # Replace with function body.

#switch to main menu and save game to that users folder
func _on_main_menu_pressed() -> void:
	AudioManager.stoplvl1Music()
	AudioManager.stopCarAmbience()
	AudioManager.stoplvl2Music()
	AudioManager.stopnature()

	get_tree().paused = false 
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		
		GameManager.endSession()
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")

#save the game and exit the game
func _on_exit_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		GameManager.endSession()
		print("Save confirmed. Quitting now...")
	get_tree().quit()
