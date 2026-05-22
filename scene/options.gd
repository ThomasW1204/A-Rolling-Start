extends Control
@onready var volume_slider = $VBoxContainer/audio # Make sure this path is correct
signal backPressed

func _ready() -> void:
	if GameManager.activeSave: #set the saved value when booted up
		
		$VBoxContainer/audio.value = GameManager.activeSave.volume
		$volume.text = "Volume: " + str(GameManager.activeSave.volume)
		
		$VBoxContainer/sens.value = GameManager.activeSave.sens
		$sensitivity.text = "Camera Sensitivity: " + str(GameManager.activeSave.sens)
		
		$VBoxContainer/speed.value = GameManager.activeSave.SPEED
		$playerSpeed.text = "Player Speed: " + str(GameManager.activeSave.SPEED)
		
	else: #have default values displayed
		$VBoxContainer/audio.value = 50.0
		$volume.text = "Volume: 100.0"
		
		$VBoxContainer/sens.value = 25
		$sensitivity.text = "Camera Sensitivity: 25"
		
		$VBoxContainer/speed.value = 8.0
		$playerSpeed.text = "Player Speed: 8" 
		
		
func _on_sens_value_changed(value: float) -> void:
	GameManager.activeSave.sens = value
	
	$sensitivity.text = "Camera Sensitivity: " + str(value)
	



func _on_audio_value_changed(value: float) -> void:
	var db_value = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db_value)
	GameManager.activeSave.volume = value
	$volume.text = "Volume: " + str(value)


	
func _on_main_menu_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	
	GameManager.save_game(player)
	
	print("clicked")
	AudioManager.buttonClick()
	backPressed.emit()


func _on_speed_value_changed(value: float) -> void:
	GameManager.activeSave.SPEED = value
	$playerSpeed.text = "Player Speed: " + str(value)
