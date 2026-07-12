extends CharacterBody2D

signal issue_clicked(employee)

@onready var name_label = $UI/NameLabel
@export var employee_name = "Employee"
@export_enum(
	"Normal",
	"Intern",
	"Manager",
	"CEO"
)
var employee_type = "Normal"
@export var walking_speed = 70
var direction_ofmovement = Vector2.ZERO
var timer_movement = 0.0

var has_issue = false
@onready var patience_bar = $UI/PatienceBar
var patience = 100
var current_issue:CyberIssue

var escalated = false

# Sprite sheet layout: player=x0, Normal=x256, Intern=x512, Manager=x768, CEO=x1024
# Each character has 4 walk frames at base_x+0, +64, +128, +192
const SPRITE_BASE_X = {
	"Normal":  256,
	"Intern":  512,
	"Manager": 768,
	"CEO":     1024,
}

func _ready():
	name_label.text = employee_name
	GameManager.register_employee(self)

	match employee_type:
		"CEO":
			patience = 70
		"Intern":
			patience = 120
		"Manager":
			patience = 90
		_:
			patience = 100

	_build_sprite_frames()

func _build_sprite_frames():
	var tex = load("res://asset/characters.png")
	if tex == null:
		return
	var base_x = SPRITE_BASE_X.get(employee_type, 256)

	var frames = SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	frames.add_animation("default")
	frames.set_animation_loop("default", true)
	frames.set_animation_speed("default", 1.0)
	var idle_at = AtlasTexture.new()
	idle_at.atlas = tex
	idle_at.region = Rect2(base_x, 0, 64, 64)
	frames.add_frame("default", idle_at)

	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 8.0)
	for f in range(4):
		var at = AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(base_x + f * 64, 0, 64, 64)
		frames.add_frame("walk", at)

	var sprite = $AnimatedSprite2D
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.play("default")

func _process(delta):
	if has_issue and !escalated:
		var exclamation = $UI/Exclamation
		if exclamation.visible:
			var pulse = 1.0 + (sin(Time.get_ticks_msec() * 0.01) * 0.1)
			exclamation.scale = Vector2(pulse, pulse)
		var urgency = current_issue.urgency
		patience -= urgency * 10 * delta
		patience_bar.value = clamp(patience,0,100)
		if patience <= 0:
			escalate()

func _physics_process(delta):
	timer_movement -= delta

	if timer_movement <= 0:
		if randf() < 0.60:
			var rand_angle = randf() * TAU
			direction_ofmovement = Vector2(cos(rand_angle), sin(rand_angle))
			timer_movement = randf_range(1.0, 3.0)
		else:
			direction_ofmovement = Vector2.ZERO
			timer_movement = randf_range(1.5, 4.0)

	velocity = direction_ofmovement * walking_speed
	move_and_slide()

	# Animation
	var sprite = $AnimatedSprite2D
	if direction_ofmovement.length() > 0.1:
		if direction_ofmovement.x < 0:
			sprite.flip_h = true
		elif direction_ofmovement.x > 0:
			sprite.flip_h = false
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "default":
			sprite.play("default")

func create_issue(issue:CyberIssue):
	has_issue = true
	escalated = false
	current_issue = issue
	match employee_type:
		"CEO":
			patience = 70
		"Intern":
			patience = 120
		"Manager":
			patience = 90
		_:
			patience = 100

	var exclamation = $UI/Exclamation
	exclamation.visible = true

	exclamation.scale = Vector2.ZERO
	var thetween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	thetween.tween_property(exclamation, "scale", Vector2(1,1), 0.5)
	GameManager.incidents_changed.emit()
	print(employee_name, "receieved issue: ", issue.issue_name)
	print(employee_name, " received issue: ", issue.issue_name)

func interact():
	if has_issue:
		issue_clicked.emit(self)

func solve():
	var solved_issue = current_issue
	if solved_issue == null:
		print("No issue to solve")
		return
	var reward = solved_issue.threat_level * 100
	GameManager.issue_solved()
	GameManager.add_score(reward)
	has_issue = false
	current_issue = null
	patience = 100
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()

func escalate():
	if escalated:
		return
	var failed_issue = current_issue
	if failed_issue == null:
		return
	escalated = true
	GameManager.issue_failed()
	print("INCIDENT ESCALATED:", failed_issue.issue_name)
	print("Consequence:", failed_issue.escalation)
	GameManager.add_score(-failed_issue.threat_level * 100)
	has_issue = false
	current_issue = null
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()
