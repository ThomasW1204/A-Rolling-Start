extends Node
var currentUser: String
var activeSave : playerSave
var player = null
var level_map = {
	1: "res://scene/main.tscn",
	2: "res://scene/level2/lvl2.tscn"
}
#save the game. used in numerous other scripts.
#if there is no activeSave then ignore
#capture the players position 
#puts the activeSave (has item information) in the current users folder as a save
func save_game(player_node: CharacterBody3D):
	#get_tree().call_group("wardrobeStall", "updateStall")

	if activeSave == null:
		return
#
	activeSave.position = player_node.global_position


	var path = "user://users/" + currentUser + "/save.tres"
	var error = ResourceSaver.save(activeSave, path)

	if error == OK:
		print("Manual save successful for: ", currentUser)
	else:
		print("Save Error: ", error)
		
func endSession():
	var active = GameManager.activeSave

	#  Create a snapshot of what just happened
	var session_snapshot = {
		"movement": active.moveData.duplicate(), 
		"collisions": active.collisionData.duplicate(),
		"level":active.currentLvl,
		"itemTotal":active.itemTotal
	}

	# Add it to history
	active.sessionHistory.append(session_snapshot)

	#  Add to the "Compiled" totals
	for key in active.moveData:
		active.totalData[key] += active.moveData[key]
		active.totalCollisions[key] += active.collisionData[key]

		#  Reset current session data for the next time they play
	active.moveData = {"forward": 0.0, "backward": 0.0, "left": 0.0, "right": 0.0}
	active.collisionData = {"forward": 0, "backward": 0, "left": 0, "right": 0}
	
	GameManager.save_game(player)

func load_and_start():
	
	if currentUser == "":
		print("Error: No currentUser set in GameManager")
		return

	var path = "user://users/" + currentUser + "/save.tres"

	#load
	if FileAccess.file_exists(path):
		activeSave = ResourceLoader.load(path)

	
	var scene_path = level_map[1] # fallback

	if activeSave:
		var saved_vol = GameManager.activeSave.volume
		var db_value = linear_to_db(saved_vol / 100.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db_value)
		
		#update level
		var lvl_index = activeSave.currentLvl
		if level_map.has(lvl_index):
			scene_path = level_map[lvl_index]

	
	print("Transitioning to: ", scene_path)
	get_tree().call_deferred("change_scene_to_file", scene_path)

func get_volume_node():
	var audio_node = get_tree().get_first_node_in_group("volumeControl")
	if audio_node:
		return audio_node
