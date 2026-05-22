extends Node3D

var gateOpened = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$itemLabel.text = "Item total: 0"
	AudioManager.playlvl2Music()
	AudioManager.playnature()
	$cave/dungeon/brokenWood.hide()
	$cave/dungeon/goodWood.show()
	$cave/dungeon/metalBars.show()
	$doorOpenLabel.hide()
	$lockedLabel.hide()
	$cave/dungeon/openMetalBars.visible = false
	if (GameManager.activeSave.barsOpen == true):
		var wood = get_node("/root/lvl2/cave/dungeon/goodWood")
		wood.queue_free()
		var bars = get_node("/root/lvl2/cave/dungeon/metalBars")
		bars.queue_free()
		
		$cave/dungeon/brokenWood.show()
		$cave/dungeon/openMetalBars.show()
		
		
	
	
	
	$exit/exitGateOpen.hide()
	$"Exit room/theEndLabel".hide()
	$"Exit room/fadeLayer".hide()
	$"Exit room/fadeLayer/overlay".hide()
	$"Exit room/Endparticles".hide()

	var player = get_tree().get_first_node_in_group("Player")
	var spawnPoint = $PlayerSpawn/Marker3D.global_position
	#var spawnPointRotation = $PlayerSpawn/Marker3D.global_rotation

	if player and GameManager.activeSave.currentLvl == 1: 
		player.global_position = spawnPoint
		player.velocity = Vector3.ZERO
		GameManager.activeSave.currentLvl = 2
	labelTimer()


func _physics_process(delta: float) -> void:
	var total2 = getLevelTwoItemCount()
	$itemLabel.text = "Item total: " + str(total2)
	#check for the open gate
	if not gateOpened:
		#var total = GameManager.activeSave.itemsPickedUp.size() + GameManager.activeSave.paintPickedUp.size()
		var total = getLevelTwoItemCount()
		#print(total)
		if total >= 4:
			openGateway()
			
func openGateway():
	gateOpened = true 
	$exit/exitGateClose.queue_free()
	$exit/exitGateOpen.show()
	$doorOpenLabel.show()
	doorlabelTimer()
	AudioManager.doorOpen()
	
func labelTimer():
	await get_tree().create_timer(5.0).timeout 
	$startLabel2.hide()
func doorlabelTimer():
	await get_tree().create_timer(5.0).timeout 
	$doorOpenLabel.hide()
func getLevelTwoItemCount():
	var count = 0
	var items = GameManager.activeSave.itemsPickedUp 
	for item in items:
		if item.contains("LV_2"):
			count+=1
				#print("loop")

	return count

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		
		if (GameManager.activeSave.barsOpen == false):
			AudioManager.doorOpen()
			var wood = get_node("/root/lvl2/cave/dungeon/goodWood")
			wood.queue_free()
			var bars = get_node("/root/lvl2/cave/dungeon/metalBars")
			bars.queue_free()
			
			$cave/dungeon/brokenWood.show()
			$cave/dungeon/openMetalBars.show()
			var node = body.get_node("caveLabel/Label")
			node.show()
			await get_tree().create_timer(3.0).timeout
			node.hide()
			GameManager.save_game(body)
			GameManager.activeSave.barsOpen= true

		
	
		
		
		
func endingLabelTimer():
	await get_tree().create_timer(5.0).timeout 
	$"Exit room/theEndLabel".hide()


func _on_endingarea_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		$"Exit room/theEndLabel".show()
		$"Exit room/Endparticles".show()
		AudioManager.hooray()
		GameManager.save_game(body)

		endingLabelTimer()


func _on_credit_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("scene change")
		#GameManager.save_game(body)
		$"Exit room/fadeLayer".show()
		$"Exit room/fadeLayer/overlay".show()
		var tween = create_tween()

		tween.tween_property($"Exit room/fadeLayer/overlay", "modulate:a", 1.0, 1.0)

		await tween.finished

		get_tree().call_deferred("change_scene_to_file", "res://scene/credits.tscn")


func _on_undermap_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var spawnPoint = $PlayerSpawn/Marker3D.global_position
		body.global_position = spawnPoint


func _on_metaldoor_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		AudioManager.lockDoor()
		$lockedLabel.show()
		lockedLabelTimer()
func lockedLabelTimer():
	await get_tree().create_timer(5.0).timeout 
	$lockedLabel.hide()
