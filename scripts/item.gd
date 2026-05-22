extends Node3D

@export var collectableMesh: PackedScene 
@export var collectableName: String = "topHat"

#ran at start of the game
#initializes all the items on map
#checks if they have been picked up in a prevous save to determine if it should be displayed or not
func _ready() -> void:
	if collectableMesh:
		var visual_instance = collectableMesh.instantiate()
		add_child(visual_instance)

	if GameManager.activeSave != null:
		if GameManager.activeSave.itemsPickedUp.has(self.name):
			print(self.name + " was already collected. Removing from world.")
			queue_free() 

#when the player enters thje area3D of the item, call equipcollectable in the player script
#remove the item from the scene
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("equipCollectable"):
		body.equipCollectable(collectableMesh,self.name) 
		print("Picked up: ", collectableName)
		queue_free()
