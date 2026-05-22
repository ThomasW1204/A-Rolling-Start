extends Node3D

var timer = 0.0
var current_prize = null # To track and delete the old item
var possibleItems 
var gatchaPool = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.activeSave != null:
		if GameManager.activeSave.gatchaInitialized:
			possibleItems = GameManager.activeSave.gatchaInv.duplicate()
			print("Restored Machine: ", possibleItems.size(), " items left.")

		else:
			possibleItems = ["res://scene/redPaint.tscn", "res://scene/yellowPaint.tscn"]
			GameManager.activeSave.gatchaInv = possibleItems.duplicate()
			GameManager.activeSave.gatchaInitialized = true
			GameManager.save_game(GameManager.player)
			print("Initialized New Machine.")

func getRandomItem():
	if is_instance_valid(current_prize):
		current_prize.queue_free()
		
	var item_to_load: String
	
	if possibleItems.size() > 0:
		var random_index = randi_range(0, possibleItems.size() - 1)
		item_to_load = possibleItems[random_index]
		var itemName = item_to_load.get_file().get_basename()
		if "paint" in itemName.to_lower():
				loadPaintScene(item_to_load)
		else:
			loadItemScene(item_to_load)
		
		possibleItems.remove_at(random_index) # Remove so it doesn't repeat
		GameManager.activeSave.gatchaInv = possibleItems
		GameManager.save_game(GameManager.player)
	else:
		item_to_load = "res://scene/duck.tscn"
	

		loadDuck(item_to_load)
	
	
	
	
	
	
	
func loadPaintScene(item):
	var itemScene = load("res://scene/paint.tscn")
	var item_content = load(item)
	
	var newItem = itemScene.instantiate()
	newItem.collectableMesh = item_content
	newItem.scale = Vector3(0.5, 0.5, 0.5)
	
	add_child(newItem)
	newItem.global_position = $Marker3D.global_position
	current_prize = newItem
	
func loadItemScene(item):
	var itemScene = load("res://scene/item.tscn")
	var item_content = load(item)
	
	var newItem = itemScene.instantiate()
	newItem.collectableMesh = item_content
	newItem.scale = Vector3(0.5, 0.5, 0.5)
	
	add_child(newItem)
	newItem.global_position = $Marker3D.global_position
	current_prize = newItem

func loadDuck(item):
	var item_resource = load(item)
	var newItem = item_resource.instantiate()

	newItem.scale = Vector3(0.05, 0.05, 0.05)
	add_child(newItem)
	newItem.global_position = $Marker3D.global_position
	current_prize = newItem

	# play the Noise
	
	if newItem.has_node("Quack"):
		newItem.get_node("Quack").play()

	#
	
	await get_tree().create_timer(3.0).timeout

	
	if is_instance_valid(newItem):
		newItem.queue_free()
		current_prize = null
	




func _on_area_3d_body_entered(body: Node3D) -> void:
	getRandomItem()
