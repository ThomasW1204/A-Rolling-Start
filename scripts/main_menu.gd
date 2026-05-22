extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.playMainMenu()



#move to user selection
func _on_start_pressed() -> void:
	AudioManager.buttonClick()
	get_tree().change_scene_to_file("res://scene/user_select.tscn")


func _on_options_pressed() -> void:
	AudioManager.buttonClick()
	
	get_tree().change_scene_to_file("res://scene/credits.tscn")

#quit the game
func _on_exit_pressed() -> void:
	AudioManager.buttonClick()
	get_tree().quit()


func _on_options_2_pressed() -> void:
	AudioManager.buttonClick()
	get_tree().change_scene_to_file("res://scene/options.tscn")
