extends Node3D

var changeInterval = 0.7
@onready var mesh = $MeshInstance3D
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = randf_range(0,changeInterval)  #each panel has different start time
	changeColor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= changeInterval:
		changeColor()
		timer = 0.0
	

func changeColor():
	var allowedColors  = [Color.RED,Color.BLUE,Color.GREEN,Color.PINK,Color.PURPLE,Color.YELLOW,Color.ORANGE]
	var indexedColor = randi_range(0,6)
	var chosenColor = allowedColors[indexedColor]
	var material = mesh.get_active_material(0)
	material.albedo_color= chosenColor
	material.emission_enabled = true
	material.emission = chosenColor
