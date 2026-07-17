extends CharacterBody2D

@export var speed = 250
var nearby_employee = null

func _ready():
	_build_sprite_frames()

func _build_sprite_frames():
	var tex = load("res://asset/characters.png")
	if tex == null:
		return
	var frames = SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	frames.add_animation("default")
	frames.set_animation_loop("default", true)
	frames.set_animation_speed("default", 1.0)
	var idle_at = AtlasTexture.new()
	idle_at.atlas = tex
	idle_at.region = Rect2(0, 0, 64, 64)
	frames.add_frame("default", idle_at)

	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 10.0)
	for f in range(4):
		var at = AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(f * 64, 0, 64, 64)
		frames.add_frame("walk", at)

	var sprite = $AnimatedSprite2D
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.play("default")

func _physics_process(_delta):
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if direction.length() > 0:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	# Animation
	var sprite = $AnimatedSprite2D
	if direction.length() > 0:
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "default":
			sprite.play("default")

func _process(_delta):
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
