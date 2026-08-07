extends CharacterBody2D

@export var speed = 250
var nearby_employee = null
var _lockdown_cleared_set: Array = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Initial state setup
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func _physics_process(_delta):
	# 1. Input vector setup
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if direction.length() > 0:
		direction = direction.normalized()
		
	velocity = direction * speed
	move_and_slide()
	
	# 2. Dynamic 4-Directional Animation Logic
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	# Single static "idle" frame when stationary
	if direction == Vector2.ZERO:
		if sprite.sprite_frames.has_animation("idle"):
			if sprite.animation != "idle":
				sprite.play("idle")
		return

	# Determine dominant movement axis for directional walk
	var target_anim: String = ""

	if abs(direction.x) >= abs(direction.y):
		if direction.x > 0:
			target_anim = "walk_right"
		else:
			target_anim = "walk_left"
	else:
		if direction.y > 0:
			target_anim = "walk_down"
		else:
			target_anim = "walk_up"

	# Disable horizontal flip 
	sprite.flip_h = false

	# Play target directional animation
	if sprite.sprite_frames.has_animation(target_anim):
		if sprite.animation != target_anim:
			sprite.play(target_anim)

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if nearby_employee == null:
			return
		if GameManager.lockdown_active:
			if not _lockdown_cleared_set.has(nearby_employee):
				_lockdown_cleared_set.append(nearby_employee)
				nearby_employee.lockdown_clear()
		elif nearby_employee.has_issue:
			nearby_employee.interact()

func reset_lockdown_cleared():
	_lockdown_cleared_set.clear()

func _on_interaction_area_body_entered(body):
	if body.is_in_group("employees"):
		nearby_employee = body

func _on_interaction_area_body_exited(body):
	if body == nearby_employee:
		nearby_employee = null
