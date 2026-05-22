extends Node3D
@export var itemName: String = ""  
@export var unlockedTexture: Texture2D 
@export var lockedTexture = preload("res://assets/images/questionMark.png") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var colorPath = 'res://scene/'+ itemName + '.tscn'

	add_to_group("wardrobeStallPaint") 
	if itemName == "whitePaint":
			$Sprite3D.texture = unlockedTexture
	updateStall()
	
	pass # Replace with function body.


		
func updateStall():
	var colorPath = 'res://scene/'+ itemName + '.tscn'

	print("-------stall check--------")
	print("looking for Item: ", GameManager.activeSave.paintPickedUp.has(colorPath))
	if GameManager.activeSave != null:
		
			
		if GameManager.activeSave.paintPickedUp.has(colorPath):
			$Sprite3D.texture = unlockedTexture
			print("unlcoked")
		else:
			$Sprite3D.texture = lockedTexture
			print("lockedf")

func _on_area_3d_body_entered(body: Node3D) -> void:
	var colorPath = 'res://scene/'+ itemName + '.tscn'

	if body.has_method("equipCollectable"):
		if GameManager.activeSave.paintPickedUp.has(colorPath):
			#var loadedPath = load(colorPath)
			body.changeColor(itemName,colorPath)
			print("equiped: ", itemName)
		else:
			print("you dont have this collectable yet")
