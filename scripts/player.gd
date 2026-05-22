extends CharacterBody3D


var SPEED:
	get:
		return GameManager.activeSave.SPEED if GameManager.activeSave else 8.0
const JUMP_VELOCITY = 4.5
@onready var player: CharacterBody3D = $"."
@onready var pivot: Node3D = $camOrgin
var sens:
	get:
		return GameManager.activeSave.sens if GameManager.activeSave else 25.0
@onready var body_mesh: MeshInstance3D = $Visuals/bodyMesh
var lastColTime : float = 0.0
var colCooldown : float = 0.75 #   between counted collisions
var mouse_input = Vector2.ZERO
var smooth_direction = Vector3.ZERO

func _input(event):
	if event is InputEventMouseMotion:
	
		var raw_input = event.relative / sens
		mouse_input = raw_input.limit_length(1.0)
		
func _ready():  #ran when game is started ONLY ONCE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$hud2/itemLabel.hide()
#	$hud2/SubViewportContainer/SubViewport.world_3d = get_viewport().find_world_3d()
	$pause.hide()
	%options.backPressed.connect(optionsBack)
	$speed/TextureRect.hide()
	$caveLabel/Label.hide()
	$optionscanvas.hide()
	GameManager.player = self
	body_mesh.set_surface_override_material(0, body_mesh.get_active_material(0).duplicate())
	if GameManager.activeSave.paintPickedUp.has("res://scene/whitePaint.tscn"):
		print("white paint picked up nothing changed")
	else:
		GameManager.activeSave.paintPickedUp.append("res://scene/whitePaint.tscn") 

	if GameManager.activeSave != null:
		global_position = GameManager.activeSave.position

	#Restore Visuals
	# Only load the item the player was wearing when they saved
	if GameManager.activeSave.itemEquiped != "":
		var hatPath = GameManager.activeSave.itemEquiped
		var loadedScene = load(hatPath)
		equipCollectable(loadedScene, "")

	if GameManager.activeSave.paintEquiped != "":
		var colorPath = GameManager.activeSave.paintEquiped
		var colorName = colorPath.get_file().get_basename()
		changeColor(colorName,colorPath)

func _physics_process(delta: float) -> void:   #called 60 times per second
	$hud2/itemLabel.text ="Item total: " + str(GameManager.activeSave.itemTotal)

	if not is_on_floor():
		velocity += get_gravity() * delta



	#  Get WASD/Keyboard Direction
	var input_dir := Input.get_vector("right", "left", "down", "up")
	var forward = pivot.global_transform.basis.z 
	var right = pivot.global_transform.basis.x
	forward.y = 0
	right.y = 0
	var wasd_direction = (forward * input_dir.y + right * input_dir.x).normalized()
	#if Input.is_action_pressed("down"):
	#	$hud2/SubViewportContainer.show()
	#	$hud2/ColorRect.show()
	#else:
	#	$hud2/SubViewportContainer.hide()
	#	$hud2/ColorRect.hide()


	#  Get Joystick/Mouse Direction
	#  use the camera's basis here too so the joystick 'up' is always 'forward'
	var joystick_direction = (forward * mouse_input.y + right * mouse_input.x).normalized()
	# If there is mouse input,  use that; otherwise, use WASD.
	var target_direction = wasd_direction
	if mouse_input.length() > 0:
		target_direction = joystick_direction

	# This creates a memory of the previous direction to stop the flickering
	smooth_direction = smooth_direction.lerp(target_direction, 0.2).normalized()

	if smooth_direction.length() > 0.1:
		
		velocity.x = move_toward(velocity.x, smooth_direction.x * SPEED, SPEED * delta * 10)
		velocity.z = move_toward(velocity.z, smooth_direction.z * SPEED, SPEED * delta * 10)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	movementData(delta)
	collisionData()
	smooth_direction = Vector3.ZERO

#	if mouse_input.y > 0.1:
#		$hud2/SubViewportContainer.show()
#		$hud2/ColorRect.show()
#	else:
#		$hud2/SubViewportContainer.hide()
#		$hud2/ColorRect.hide()

	if Input.is_action_just_pressed("quit"):
		var new_pause_state = !get_tree().paused
		get_tree().paused = new_pause_state

		if new_pause_state:
			$pause.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			$pause.hide()
			$optionscanvas.hide() # Force close options 
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Cleanup and Physics
	mouse_input = Vector2.ZERO # Reset for next frame
	move_and_slide()
	#$hatAnchor.global_rotation = Vector3.ZERO
	
	#handleCharRotation(delta) #character rotations
	handleVisualRotation(delta)
	handleCamRotation() #camera rotations
	#handleGrowth(delta)
	eyeRotation()
	

func handleVisualRotation(delta):
	# Only rotate if moving
	if velocity.length() > 0.2:
	#  Calculate the target angle based on current velocity
		var target_angle = atan2(-velocity.x, -velocity.z)

	# Smoothly rotate the Visuals container using lerp_angle
	
		$Visuals.rotation.y = lerp_angle($Visuals.rotation.y, target_angle, 0.15)
		$RemoteTransform3D.rotation.y=lerp_angle($Visuals.rotation.y, target_angle, 0.15)

	# Handle the Rolling effect for the bodyMesh 
		var mesh_size = body_mesh.get_aabb().size
		var radius = (mesh_size.x / 2.0) * body_mesh.scale.x
		var rotationAngle = (SPEED * delta) / radius
		var rollAxis = Vector3(velocity.z, 0, -velocity.x).normalized()

		if rollAxis.length() > 0:
			body_mesh.global_rotate(rollAxis, rotationAngle)


func eyeRotation():
	
	
	var current_radius = 0.5 * body_mesh.scale.x 
	var surface_distance = current_radius + 0.05


	$Visuals/eye1.position = Vector3(0.2, 0, -surface_distance)
	$Visuals/eye2.position = Vector3(-0.2, 0, -surface_distance)

	$Visuals/hatAnchor.position = Vector3(0, current_radius, 0)

'''
func handleCamRotation():
	if velocity.length() > 1.5:
		var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

		var move_angle = atan2(horizontal_velocity.x, horizontal_velocity.z)

		# wrap_pi keeps the difference between -PI and PI (-180 to 180 degrees) 
		var angle_diff = abs(angle_difference(pivot.rotation.y, move_angle))

		# it means we are moving 'away' from where the camera looks [cite: 32, 76]
		if angle_diff < 2.0: 
		# Only lerp if we are facing 'Forward-ish'
			pivot.rotation.y = lerp_angle(pivot.rotation.y, move_angle, 0.02)
		else:
		# Moving backward or sharp reverse? Freeze the camera. [cite: 32, 76]
			pass
	'''
	
func handleCamRotation():
	if velocity.length() > 1.5:
		var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
		var move_angle = atan2(horizontal_velocity.x, horizontal_velocity.z)
		var angle_diff = abs(angle_difference(pivot.rotation.y, move_angle))

		if angle_diff < 2.0: 
			var dynamic_sens = clamp(sens / 1000.0, 0.001, 0.1) 
			pivot.rotation.y = lerp_angle(pivot.rotation.y, move_angle, dynamic_sens)
	
	
	
			
#make the player grow in size as they move and update the hud
func handleGrowth(delta):
	var growth = Vector3(0.03,0.03,0.03) * delta #the growth per movement
	if velocity.length() > 1:
		scale += growth
		scale.x = clamp(scale.x, 1, 5) #sets min and max size for player
		scale.y = scale.x
		scale.z = scale.x
		$hud/sizeLabel.text ="Size: %0.1f" % scale.x #update HUD




#equips the collectable to the player. 
#saves the currently equipped item in the active save var.
#saves the fact that the user has picked up that item, preventing it from spawning again
func equipCollectable(itemScene, itemID: String):
	if itemScene == null:
		return
	AudioManager.playEquipSound()
	#  Physical Swap 
	for child in $Visuals/hatAnchor.get_children():
		child.queue_free()

	var item = itemScene.instantiate()
	$Visuals/hatAnchor.add_child(item)
	item.position = Vector3.ZERO
	#  Save Logic 
	if GameManager.activeSave != null:
	# Check if this is a newly discovered item
		if not GameManager.activeSave.itemsPickedUp.has(itemID) and itemID != "":
			GameManager.activeSave.itemsPickedUp.append(itemID)

			#  update what is currently equipped
			GameManager.activeSave.itemEquiped = itemScene.resource_path
			GameManager.activeSave.itemTotal +=1

			GameManager.save_game(self) 
			get_tree().call_group("wardrobeStall", "updateStall")

func changeColor(color, colorPath):
	var material = body_mesh.get_active_material(0) # Grabs the first material slot		
	AudioManager.playEquipSound()

	if color == "redPaint":
		material.albedo_color = Color.RED
	if color == "yellowPaint":
		material.albedo_color = Color.YELLOW
	if color == "whitePaint":
		material.albedo_color = Color.WHITE
	if color == "greenPaint":
		material.albedo_color = Color.WEB_GREEN
	
	if GameManager.activeSave != null:
		if not GameManager.activeSave.paintPickedUp.has(colorPath):
			GameManager.activeSave.paintPickedUp.append(colorPath)
			GameManager.activeSave.itemTotal +=1 

	GameManager.activeSave.paintEquiped = colorPath
	GameManager.save_game(player)


'''
func movementData(delta):
	if GameManager.activeSave == null:
		return
		
	var input_dir = Input.get_vector("left", "right", "up", "down")

	var data = GameManager.activeSave.moveData
	if input_dir.y < 0:
		data["forward"] += delta
	elif input_dir.y > 0:
		data["backward"] += delta
	if input_dir.x < 0:
		data["left"] += delta
	elif input_dir.x > 0:
		data["right"] += delta
	
func collisionData():
	if GameManager.activeSave == null:
		return
	var currentTime = Time.get_ticks_msec() / 1000.0
	
	if get_slide_collision_count() > 0 and (currentTime - lastColTime) > colCooldown:	
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var data = GameManager.activeSave.collisionData
		
		if input_dir.y < 0:
			data["forward"] += 1
		elif input_dir.y > 0:
			data["backward"] += 1
		if input_dir.x < 0:
			data["left"] += 1
		elif input_dir.x > 0:
			data["right"] += 1
	
		lastColTime = currentTime
		

'''
func movementData(delta):
	if GameManager.activeSave == null or smooth_direction.length() < 0.1:
		return

	# Transform global movement into the Camera's local space
	var local_dir = pivot.global_transform.basis.inverse() * smooth_direction
	var data = GameManager.activeSave.moveData

	if local_dir.z > 0.1:    # Positive Z is Forward
		data["forward"] += delta
	elif local_dir.z < -0.1: # Negative Z is Backward
		data["backward"] += delta

	if local_dir.x > 0.1:    # Positive X is Left
		data["left"] += delta
	elif local_dir.x < -0.1: # Negative X is Right
		data["right"] += delta
		
func collisionData():
	if GameManager.activeSave == null:
		return

	var currentTime = Time.get_ticks_msec() / 1000.0

	if get_slide_collision_count() > 0 and (currentTime - lastColTime) > colCooldown:
		var hit_something_valid = false

		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

		# If the thing we hit is not on Layer 2 (The Floor)
		# This means we hit a building, a wall, or a car.
			if not collider.get_collision_layer_value(2):
				hit_something_valid = true
				break 

		if hit_something_valid:
			# Use  local_dir logic to log the direction
			var local_dir = pivot.global_transform.basis.inverse() * smooth_direction
			var data = GameManager.activeSave.collisionData

			if local_dir.z > 0.1:
				data["forward"] += 1
			elif local_dir.z < -0.1:
				data["backward"] += 1

			if local_dir.x > 0.1:
				data["left"] += 1
			elif local_dir.x < -0.1:
				var data_right = data["right"] 
				data["right"] += 1

			lastColTime = currentTime
			
func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("activeTraffic") or (body.owner and body.owner.is_in_group("activeTraffic")):
		print("MATCH FOUND on Car Owner! Respawning...")
		respawnPlayer()


func respawnPlayer():
	var marker = get_tree().get_first_node_in_group("spawnMarker")
	set_physics_process(false) 
	await get_tree().create_timer(0.3).timeout
	set_physics_process(true)
	
	global_position = marker.global_position



func optionsBack():
	print("in optionsbvack")
	$optionscanvas.hide()
	$pause.show()
