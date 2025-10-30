extends Area3D

var ROT_SPEED = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	var tween = get_tree().create_tween()

	# Making the coin pop up slightly
	tween.tween_property(self, "position", position - Vector3(0, -2.5, 0), 0.3)
	$CoinCling.play()
	# Delay for 1 seconds before starting fade-out effect
	await get_tree().create_timer(1.0).timeout

	# Get the MeshInstance3D to apply transparency
	var mesh_instance = $MeshInstance3D

	if mesh_instance.material_override == null:
		mesh_instance.material_override = StandardMaterial3D.new()

	# Ensuring that transparency is enabled, matsku
	var material = mesh_instance.material_override
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# Fade out effect by reducing the alpha component over 1 second
	var start_color = material.albedo_color
	var end_color = start_color
	end_color.a = 0  # Set target alpha to 0 (fully transparent)

	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(material, "albedo_color", end_color, 1.0)

	# Queue for deletion after the fade-out effect
	fade_tween.tween_callback(queue_free)
