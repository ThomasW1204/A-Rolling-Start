extends Node3D




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var boost_ui = body.get_node("speed/TextureRect")
		var save_data = GameManager.activeSave

		# Store the  speed they had before the boost
		var original_speed = save_data.SPEED 

		#  Start the Boost
		boost_ui.show()
		save_data.SPEED = original_speed * 5.0 

		var tween = create_tween()
		# Use original_speed as the target 
		tween.tween_property(save_data, "SPEED", original_speed, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		await tween.finished
		boost_ui.hide()

		# snap to original speed
		save_data.SPEED = original_speed
