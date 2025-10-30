extends RigidBody3D

var ROT_SPEED = 4
var coin_collected = false  # Flag to prevent further interactions

# Called when the node enters the scene tree for the first time
func _physics_process(delta: float):
	# Rotate the coin continuously if it has not been collected
	if not coin_collected:
		rotate_y(deg_to_rad(ROT_SPEED))

func _on_collect_box_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	# Prevent multiple triggers
	if coin_collected:
		return

	# Mark the coin as collected
	coin_collected = true

	# Increment the score by accessing the ScoreLabel node
	var score_label = get_node("../../Camera3D/ScoreLabel")  # Adjust this path as needed
	if score_label:
		score_label.add_score(100)  # Add 100 to the score

	# Add visual and sound effects for coin collection
	var tween = get_tree().create_tween()
	var target_position = global_transform.origin + Vector3(0, 2.5, 0)  # Move upwards in global space
	tween.tween_property(self, "global_transform:origin", target_position, 0.3)  # Use global_transform for precise motion

	# Play the sound effect
	$CoinCling.play()

	# Get the MeshInstance3D to apply transparency
	var mesh_instance = $MeshInstance3D
	if mesh_instance.material_override == null:
		mesh_instance.material_override = StandardMaterial3D.new()

	var material = mesh_instance.material_override
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# Fade out effect
	var start_color = material.albedo_color
	var end_color = start_color
	end_color.a = 0

	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(material, "albedo_color", end_color, 1.0)
	fade_tween.tween_callback(queue_free)

	# Disable further collisions safely using call_deferred()
	$CollisionShape3D.call_deferred("set_disabled", true)
