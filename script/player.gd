extends CharacterBody2D


@export var speed = 250

var nearby_employee = null



func _physics_process(delta):
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if direction.length() > 0:
		direction = direction.normalized()

	velocity = direction * speed

	move_and_slide()



func _process(delta):
	if Input.is_action_just_pressed("interact"):
		print("Pressed E")
		if nearby_employee:
			print("Talking to:", nearby_employee.name)
			nearby_employee.interact()



func _on_interaction_area_body_entered(body):
	if body.is_in_group("employees"):
		nearby_employee = body
		print("Nearby:", body.name)



func _on_interaction_area_body_exited(body):
	if body == nearby_employee:
		nearby_employee = null
		print("Left:", body.name)
