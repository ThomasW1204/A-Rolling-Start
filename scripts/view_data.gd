extends Node2D

#needs active user
#displays the data for that user
#alows for exporet of that data to csv?
var user = GameManager.currentUser

# Called when the node enters the scene tree for the first time.
#sets text and alignment of labels then if theres a active save and it has move data then display that data via displaydata()
func _ready() -> void:
	$Label.text = "data for: " + user
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if GameManager.activeSave and GameManager.activeSave.moveData and GameManager.activeSave.collisionData:
		_displayData()
		_displayFullData()
	else:
		$Label.text = "No data found for " + user


#display the data in the vbox container. 
#create labels for each key value pair from gameManager.movedata 
func _displayData():
	for child in $CenterContainer/HBoxContainer/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
	var historyData = GameManager.activeSave.sessionHistory
	for i in range(historyData.size()):
		var totalTime = 0.0  

		var session = historyData[i]
		var sessionLabel = Label.new()
		sessionLabel.text = "
		Session: %s " % (i+1)
		sessionLabel.horizontal_alignment= HORIZONTAL_ALIGNMENT_CENTER
		var levelLabel = Label.new()
		var level = session.get("level", "unknown")
		levelLabel.text = "Current level: " + str(level)
		levelLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		var itemLabel = Label.new()
		var itemCount = session.get("itemTotal", "unknown") 
		itemLabel.text = "Total items collected: " + str(itemCount-1)
		itemLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$CenterContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(sessionLabel)
		$CenterContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(levelLabel)
		$CenterContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(itemLabel)

		for entry in session.movement:
			var cleanSeconds = int(session.movement[entry])
			totalTime += cleanSeconds
			var sessionDataLabel = Label.new()
			var formatedTime = calculateMin(cleanSeconds)	
			sessionDataLabel.text = "%s: %s (%d Collisions)" % [entry.capitalize(), formatedTime, session.collisions[entry]]
			sessionDataLabel.horizontal_alignment= HORIZONTAL_ALIGNMENT_CENTER
			$CenterContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(sessionDataLabel)
		var totalTimeLabel = Label.new()
		var formattedTotal = calculateMin(totalTime)
		totalTimeLabel.text = "Total session time: " + formattedTotal
		totalTimeLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# Style so it stands out from the individual directions
		#totalTimeLabel.add_theme_color_override("font_color", Color.CYAN)
		$CenterContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(totalTimeLabel)
			
			
			
#shows the total data ont he right
func _displayFullData():
	var grandTotalTime = 0.0
	for child in $CenterContainer/HBoxContainer/totalcontainerVbox.get_children():
		child.queue_free()
	var header = Label.new()
	header.text = "OVERALL TOTALS"
	$CenterContainer/HBoxContainer/totalcontainerVbox.add_child(header)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var totals = GameManager.activeSave.totalData 
	var total_cols = GameManager.activeSave.totalCollisions
	var curlevel = GameManager.activeSave.currentLvl
	var itemTotal = GameManager.activeSave.itemTotal -1
	var levelLabel = Label.new()
	#var level = totals.get("level", "unknown")
	levelLabel.text = "Current level: " + str(curlevel)
	levelLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var itemLabel = Label.new()
	#var itemCount = totals.get("itemTotal", "unknown") 
	itemLabel.text = "Total items collected: " + str(itemTotal)
	itemLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER	
	$CenterContainer/HBoxContainer/totalcontainerVbox.add_child(levelLabel)
	$CenterContainer/HBoxContainer/totalcontainerVbox.add_child(itemLabel)

	for entry in totals:
		var totalLabel = Label.new()
		var cleanSeconds = int(totals[entry])
		grandTotalTime += cleanSeconds
		var timeStr = calculateMin(cleanSeconds)
		totalLabel.text = "%s: %s (%d Collisions)" % [entry.capitalize(), timeStr, total_cols[entry]]
		totalLabel.horizontal_alignment= HORIZONTAL_ALIGNMENT_CENTER
		$CenterContainer/HBoxContainer/totalcontainerVbox.add_child(totalLabel)
	var grandTotalLabel = Label.new()
	var formattedGrandTotal = calculateMin(grandTotalTime)
	grandTotalLabel.text = "GRAND TOTAL TIME: " + formattedGrandTotal
	grandTotalLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	#grandTotalLabel.add_theme_color_override("font_color", Color.CHARTREUSE)
	$CenterContainer/HBoxContainer/totalcontainerVbox.add_child(grandTotalLabel)
			

#export as a csv into the downloads folder and open the folder 
func _export():
	var downloadsFolder = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	var fileName = "/UserData_" + GameManager.currentUser + ".csv"
	var fullPath = downloadsFolder + fileName

	var file = FileAccess.open(fullPath, FileAccess.WRITE)
	if file:
		file.store_line("Session_Number,Current Level,Total Items Collected,Direction,Time(MM:SS),Collisions,Total Session Time")

		var order = ["forward", "backward", "left", "right"]
		var history = GameManager.activeSave.sessionHistory
		var curLevel = GameManager.activeSave.currentLvl
		var totalItems = GameManager.activeSave.itemTotal

		for i in range(history.size()):
			var session = history[i]
			var sessionLevel = session.get("level", curLevel)
			var sessionItems = session.get("itemTotal", totalItems) - 1

			var sessionTotalTime = 0.0
			for dir in session.movement:
				sessionTotalTime += session.movement[dir]
			var formattedTotal = calculateMin(sessionTotalTime)

			for dir in order:
				if session.movement.has(dir):
					var formattedTime = calculateMin(session.movement[dir])
					var row = "%d,%s,%d,%s,%s,%d,%s" % [
					i + 1, 
					sessionLevel, 
					sessionItems, 
					dir.capitalize(), 
					formattedTime, 
					session.collisions[dir],
					formattedTotal
					]
					file.store_line(row)

			file.store_line("") 

		# Overall Totals
		file.store_line("OVERALL TOTALS")
		file.store_line("Direction,Current Level,Total Items Collected,Total Time,Total Collisions,Grand Total Time")

		var grandTotalSeconds = 0.0
		for dir in order:
			grandTotalSeconds += GameManager.activeSave.totalData[dir]
		var formattedGrandTotal = calculateMin(grandTotalSeconds)

		var finalLevel = GameManager.activeSave.currentLvl
		var finalItems = GameManager.activeSave.itemTotal - 1

		for dir in order:
			var total_time_str = calculateMin(GameManager.activeSave.totalData[dir])
			var collisions = GameManager.activeSave.totalCollisions[dir]

			var row = "%s,%s,%d,%s,%d,%s" % [
			dir.capitalize(),    # Direction
			finalLevel,          # Current Level
			finalItems,          # Total Items Collected
			total_time_str,      # Total Time (per direction)
			collisions,          # Total Collisions (per direction)
			formattedGrandTotal  # Grand Total Time
			]
			file.store_line(row)
		file.close()
		OS.shell_open(downloadsFolder)
	else:
		print("couldn't access downloads folder")


func _on_export_button_pressed() -> void:
	AudioManager.buttonClick()
	_export()
	


func _on_back_button_pressed() -> void:
	AudioManager.buttonClick()

	get_tree().call_deferred("change_scene_to_file","res://scene/user_select.tscn")


func calculateMin(totalTime:float):
	var minutes := int(totalTime / 60)
	var seconds := int(totalTime) % 60
	return "%d:%02d" % [minutes, seconds]
