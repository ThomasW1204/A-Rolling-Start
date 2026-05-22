extends Node3D
var carPool = ["res://scene/taxi.tscn", "res://scene/hatchback_sports.tscn", "res://scene/ambulance.tscn"]
var gateOpened = false
func _ready() -> void:
	AudioManager.playlvl1Music()
	AudioManager.playCarAmbience()
	$sceneChange/fadeLayer.hide()
	$sceneChange/fadeLayer/overlay.hide()
	$doorLabel.hide()
	#get_tree().connect("item_count_changed", _on_item_count_changed)
	labelTimer()
	spawnTimer()
	GameManager.activeSave.currentLvl = 1
		
	
func _physics_process(delta: float) -> void:
	var all_cars = get_tree().get_nodes_in_group("activeTraffic")
	for car in all_cars:
		if is_instance_valid(car):
			var speed = car.get_meta("speed", 0.2)
			car.global_position.x += speed * delta
			if abs(car.global_position.x) > 300:
				car.queue_free()
	#var total2 = GameManager.activeSave.itemsPickedUp.size() + GameManager.activeSave.paintPickedUp.size()
	var itemTotal = getItemCount()
	$itemLabel.text = "Item Total: " + str(itemTotal-1)

	#check for the open gate
	if not gateOpened:
		var total = GameManager.activeSave.itemsPickedUp.size() + GameManager.activeSave.paintPickedUp.size()
		if total >= 4:
			openGateway()
			
#item counts were giving issues so manually check by looping through
func getItemCount():
	var itemCount = 0
	var paintCount = 0
	var items = GameManager.activeSave.itemsPickedUp 
	var paint =  GameManager.activeSave.paintPickedUp
	for item in items:
			itemCount+=1
	for item in paint:
		paintCount+=1
		
	var totalCount = itemCount+paintCount
	return totalCount
	
func labelTimer():
	await get_tree().create_timer(5.0).timeout 
	$startLabel.hide()
func labelTimer2():
	await get_tree().create_timer(5.0).timeout 
	$doorLabel.hide()
func spawnTimer():
	var randomf = randf_range(2.0, 6.0)
	await get_tree().create_timer(randomf).timeout
	spawnCar()
		
func spawnCar():
	var randomIndex = randi_range(0, carPool.size()-1)
	var finCar = load(carPool[randomIndex]).instantiate()
	finCar.add_to_group("activeTraffic")
	add_child(finCar)
	finCar.scale = Vector3(2.5,2.5,2.5)

	var direction = 1 if randf() > 0.5 else -1
	if direction == 1:
		finCar.global_position = $movingCars/close.global_position
		finCar.set_meta("speed", 10.0) 
		finCar.rotation = Vector3(0,-80.1,0)

	else:
		finCar.global_position = $movingCars/far.global_position
		finCar.set_meta("speed", -10.0)
		finCar.rotation = Vector3(0,80.1,0)

	spawnTimer()

func openGateway():
	gateOpened = true 
	AudioManager.doorOpen()
	$doorLabel.show()
	labelTimer2()
	$exitGate.queue_free()


	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("scene change")
		#GameManager.activeSave.currentLvl = 2
		GameManager.save_game(body)
		$sceneChange/fadeLayer.show()
		$sceneChange/fadeLayer/overlay.show()
		var tween = create_tween()

		#transition animation
		tween.tween_property($sceneChange/fadeLayer/overlay, "modulate:a", 1.0, 1.0)

		await tween.finished
		
		$itemLabel.hide()
		AudioManager.stoplvl1Music()
		AudioManager.stopCarAmbience()
		get_tree().call_deferred("change_scene_to_file", "res://scene/level2/lvl2.tscn")
