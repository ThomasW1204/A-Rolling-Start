extends Control

@export var scroll_speed = 50
@export var section_spacing = 70 # Space between different roles
@export var line_spacing = 45    # Space between header and name
var active_labels = []

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var file = FileAccess.open("res://credits.txt", FileAccess.READ)
	if file:
		var y_offset = get_viewport_rect().size.y
		
		while not file.eof_reached():
			var line_text = file.get_line()
			if line_text.strip_edges() == "": continue
			
			#  Split the line into Header and Name
			var parts = line_text.split(":-")
			
			if parts.size() == 2:
				# Spawn the HEADER
				spawn_label(parts[0].strip_edges(), y_offset, Color.BLACK, 40)
				y_offset += line_spacing
				
				# Spawn the NAME 
				spawn_label(parts[1].strip_edges(), y_offset, Color.WHITE, 32)
				y_offset += section_spacing
			else:
				#  spawn a normal line
				spawn_label(line_text, y_offset, Color.WHITE, 22)
				y_offset += section_spacing

func spawn_label(text_val: String, y_pos: float, color: Color, size: int):
	var lbl = Label.new()
	lbl.text = text_val
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size.x = get_viewport_rect().size.x
	lbl.position = Vector2(0, y_pos)
	
	# Style
	if(text_val.contains("//")): #if url have different text size
		lbl.add_theme_font_size_override("font_size", 16)
	else:
		lbl.add_theme_font_size_override("font_size", size)
	
	lbl.add_theme_color_override("font_color", color)

	add_child(lbl)
	active_labels.append(lbl)

#if you dont wanna sit through credits 
func _input(event):
	if event is InputEventMouseButton or event is InputEventKey:
		if event.pressed:
			AudioManager.stoplvl2Music()
			get_tree().change_scene_to_file("res://scene/main_menu.tscn")

			
func _process(delta):
	if active_labels.is_empty():
		AudioManager.stoplvl2Music()
		get_tree().change_scene_to_file("res://scene/main_menu.tscn")
		return

	for i in range(active_labels.size() - 1, -1, -1):
		var lbl = active_labels[i]
		lbl.position.y -= scroll_speed * delta
		if lbl.position.y < -100:
			lbl.queue_free()
			active_labels.remove_at(i)
