extends Node3D

@export var collectableMesh: PackedScene 
@export var collectableName: String = ""

#ran at start of the game
#initializes all the items on map
#checks if they have been picked up in a prevous save to determine if it should be displayed or not
func _ready() -> void:
	if collectableMesh:
		var visual_instance = collectableMesh.instantiate()
		add_child(visual_instance)
	var colorPath = collectableMesh.resource_path
	if GameManager.activeSave != null:
		if GameManager.activeSave.paintPickedUp.has(colorPath):
			print(colorPath + " was already collected. Removing from world.")
			queue_free() 

#when the player enters thje area3D of the item
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("changeColor"):
		var full_path = collectableMesh.resource_path 
		# Strip the path down to just the name
		var sceneName = full_path.get_file().get_basename()
		
		body.changeColor(sceneName, full_path) 
		get_tree().call_group("wardrobeStallPaint", "updateStall")

		print(" changed color to: ", collectableName)
		queue_free()
