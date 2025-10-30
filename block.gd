extends Node3D

var Player

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]

func _on_hurt_box_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered hurtbox!")
		# Immediately damage the player on impact
		body.hurt(1)  # Apply 1 damage immediately
		# Start the damage timer for periodic damage
		body.damage_timer.start()

func _on_hurt_box_body_exited(body):
	if body.is_in_group("Player"):
		print("Player exited hurtbox!")
		# Stop the damage timer when the player exits the hurtbox area
		body.damage_timer.stop()
