extends Node3D
@export var itemName: String = ""  
@export var unlockedTexture: Texture2D 
@export var lockedTexture = preload("res://assets/images/questionMark.png") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("wardrobeStall") 
	updateStall()


		
func updateStall():
	print("-------stall check--------")
	print("looking for Item: ", GameManager.activeSave.itemsPickedUp.has(itemName))
	if GameManager.activeSave != null:
		if GameManager.activeSave.itemsPickedUp.has(itemName):
			$Sprite3D.texture = unlockedTexture
			print("unlcoked")
		else:
			$Sprite3D.texture = lockedTexture
			print("lockedf")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("equipCollectable"):
		if GameManager.activeSave.itemsPickedUp.has(itemName):
			if itemName.contains("LV_2"):
				var path = 'res://scene/level2/Lvl2AssetScenes/pickups/'+ itemName + '.tscn'
				var loadedPath = load(path)
				body.equipCollectable(loadedPath,itemName)
				print("equiped: ", itemName)
			else:
				var path = 'res://scene/'+ itemName + '.tscn'
				var loadedPath = load(path)
				body.equipCollectable(loadedPath,itemName)
				print("equiped: ", itemName)
		else:
			print("you dont have this collectable yet")
