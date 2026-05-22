extends Node2D
var user_to_delete: String = ""
var row_to_delete: Node = null
var userSelected = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/Label.hide()
	$PopupPanel.hide()
	if not DirAccess.dir_exists_absolute("user://users/"):
		DirAccess.make_dir_absolute("user://users/")
	getUserButtons()


#read the title of the folders in the users folder
#the name of the subfolders are the users
func getUsers():
	var usersFolder = DirAccess.open("user://users/")
	var individualUsers = usersFolder.get_directories()
	return individualUsers

#when enter is pressed in text box:
#check and see if the that name is already in user directory
#if its already in directory display label saying try again
#if its not then call to create newUser
func _on_line_edit_text_submitted(new_text: String) -> void:
	AudioManager.newUser()
	var userList = getUsers()
	var newUser = new_text.to_lower()
	var userExists = false
	
	for user in userList:
		if newUser == user.to_lower():
			userExists = true
	
	if userExists:
		$Control/Label.show()
	else:
		$Control/Label.hide()
		$Control/LineEdit.clear()
		addUserToList(newUser)
		getUserButtons()
	pass

#adds user in the directory/list
func addUserToList(newUser: String):
	var usersFolder = DirAccess.open("user://users/")
	usersFolder.make_dir(newUser)

#dynamically displays the user buttons and delete buttons on the left.

func getUserButtons():
	for child in $VBoxContainer.get_children():
		child.queue_free()

	var userList = getUsers()
	for user in userList:
		var hbox = HBoxContainer.new()
		hbox.alignment =BoxContainer.ALIGNMENT_CENTER
		$VBoxContainer.add_child(hbox)
		
		print(user)
		
		var userButton = Button.new()
		userButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		userButton.text = user
		var userName = str(user)
		userButton.pressed.connect(_on_userButton_pressed.bind(userName))
		hbox.add_child(userButton)
		
		var save_path = "user://users/" + user + "/save.tres"
		if FileAccess.file_exists(save_path):
			var temp_save = ResourceLoader.load(save_path)
			if temp_save and "completionFlag" in temp_save and temp_save.completionFlag == true:
				var star = TextureRect.new()
				star.texture = load("res://art/starIcon.png") 
				star.expand_mode = TextureRect.STRETCH_KEEP_ASPECT
				star.custom_minimum_size = Vector2(25, 25) 
				star.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
				hbox.add_child(star)

		
		
		
		
		
		
		var deleteButton = Button.new()
		deleteButton.text = "X"
		hbox.add_child(deleteButton)
		deleteButton.pressed.connect(_on_delete_pressed.bind(user,hbox))
		



#When the delete button is pressed pop up a confirmation
func _on_delete_pressed(userName:String, Row:Node):
	AudioManager.buttonClick()

	user_to_delete = userName
	row_to_delete = Row
	$ConfirmationDialog.dialog_text = "Are you sure you want to delete " + userName + " and all their saved data?"
	$ConfirmationDialog.popup_centered()
	

#if the user presses confirm, move that user file to the trash
#also remove the user buttons/row from UI
func _on_confirmation_dialog_confirmed():
	AudioManager.buttonClick()
	if user_to_delete == "" or row_to_delete == null:
		return

	# Delete the folder
	var path = "user://users/" + user_to_delete
	OS.move_to_trash(ProjectSettings.globalize_path(path))

	row_to_delete.queue_free()

	user_to_delete = ""
	row_to_delete = null

#when a user button is selected popup a window and set the selected user
func _on_userButton_pressed(user):
	AudioManager.buttonClick()
	$PopupPanel.popup_centered()
	$PopupPanel.show()
	userSelected = user 
#	var path = "user://users/" + user + "/save.tres"
#	if FileAccess.file_exists(path):
#		GameManager.activeSave = ResourceLoader.load(path)
#	else:
#		GameManager.activeSave = playerSave.new()
#		GameManager.activeSave.position = Vector3(-0.6, 1.322, -14.877)
#	get_tree().change_scene_to_file("res://scene/main.tscn")


#when resume is selected access that users folder and load that users variables
#if the user doesnt have a save, simply start a new one.
func _on_resume_pressed() -> void:
	AudioManager.buttonClick()
	AudioManager.stopMainMenu()
	var user = userSelected
	GameManager.currentUser = user 
	var path = "user://users/" + user + "/save.tres"
	if FileAccess.file_exists(path):
		GameManager.activeSave = ResourceLoader.load(path)
	else:
		GameManager.activeSave = playerSave.new()
		GameManager.activeSave.currentLvl = 1
		GameManager.activeSave.position = Vector3(-0.6, 1.322, -14.877)

		DirAccess.make_dir_recursive_absolute("user://users/" + user)
		ResourceSaver.save(GameManager.activeSave, path)

	GameManager.load_and_start()


func _on_view_data_pressed() -> void:
	AudioManager.buttonClick()
	var user = userSelected
	GameManager.currentUser = user
	var path = "user://users/" + user + "/save.tres"
	if FileAccess.file_exists(path):
		GameManager.activeSave = ResourceLoader.load(path)
	else:
		GameManager.activeSave = playerSave.new()
		GameManager.activeSave.position = Vector3(-0.6, 1.322, -14.877)
	get_tree().call_deferred("change_scene_to_file","res://scene/view_data.tscn")
	

func _on_cancel_pressed() -> void:
	AudioManager.buttonClick()
	$PopupPanel.hide()
	userSelected = "" 


func _on_back_button_pressed() -> void:
	AudioManager.buttonClick()
	get_tree().call_deferred("change_scene_to_file","res://scene/main_menu.tscn")
