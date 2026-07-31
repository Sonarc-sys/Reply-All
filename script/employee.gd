extends CharacterBody2D

signal issue_clicked(employee)

@onready var name_label = $UI/NameLabel
@export var employee_name = "Employee"
@export_enum(
	"IT_NPC",
	"Worker_D",
	"Intern_A",
	"Intern_B",
	"CEO",
	"Receptionist",
	"Worker_A",
	"Worker_B",
	"Worker_C"
) var employee_type = "Worker_A"

@export var walking_speed = 30

const SPRITE_BASE_X = {
	# Sheet is 1280px wide: 5 chars x 4 frames x 64px = slots at 0,256,512,768,1024
	"Player":        0,
	"IT_NPC":        256,
	"Worker_D":      256,
	"Intern_A":      768,
	"Intern_B":      1024,
	"CEO":           512,
	"Receptionist":  768,
	"Worker_C":      1024,
	"Worker_A":      256,
	"Worker_B":      512,
	"Normal3":       768,
	"Normal4":       1024,
}

# Per-role patience and drain only — movement is handled simply below
const ROLE_CONFIG = {
	"IT_NPC":       { "patience": 85,  "drain": 1.2, "walk_chance": 0.10, "speed": 18 },
	"Worker_D":     { "patience": 85,  "drain": 1.2, "walk_chance": 0.10, "speed": 18 },
	"CEO":          { "patience": 120,  "drain": 1.0, "walk_chance": 0.05, "speed": 15 },
	"Intern_A":     { "patience": 130, "drain": 0.7, "walk_chance": 0.20, "speed": 22 },
	"Intern_B":     { "patience": 130, "drain": 0.7, "walk_chance": 0.20, "speed": 22 },
	"Receptionist": { "patience": 100, "drain": 1.0, "walk_chance": 0.05, "speed": 15 },
	"Worker_A":     { "patience": 100, "drain": 1.0, "walk_chance": 0.10, "speed": 18 },
	"Worker_B":     { "patience": 100, "drain": 1.0, "walk_chance": 0.10, "speed": 18 },
	"Worker_C":     { "patience": 100, "drain": 1.0, "walk_chance": 0.10, "speed": 18 },
}
const DEFAULT_CFG = { "patience": 100, "drain": 1.0, "walk_chance": 0.10, "speed": 18 }

var _cfg: Dictionary = {}

# Simple original-style movement
var direction_ofmovement = Vector2.ZERO
var timer_movement = 0.0

var has_issue = false
@onready var patience_bar = $UI/PatienceBar
var patience = 100
var current_issue: CyberIssue
var escalated = false

func _ready():
	name_label.text = employee_name
	GameManager.register_employee(self)
	_cfg = ROLE_CONFIG.get(employee_type, DEFAULT_CFG)
	patience = _cfg["patience"]
	$UI/Exclamation.visible = false
	_build_sprite_frames()
	timer_movement = randf_range(2.0, 8.0)

func _build_sprite_frames():
	var tex = load("res://asset/characters.png")
	if tex == null: return
	var base_x = SPRITE_BASE_X.get(employee_type, 2048)
	var frames = SpriteFrames.new()
	if frames.has_animation("default"): frames.remove_animation("default")
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
		var excl = $UI/Exclamation
		if excl.visible:
			var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.1
			excl.scale = Vector2(pulse, pulse)
		patience -= current_issue.urgency * 10.0 * delta * _cfg["drain"]
		patience_bar.value = clamp(patience, 0, 100)
		if patience <= 0:
			escalate()

func _physics_process(delta):
	# Original simple timer-based movement — very slow, mostly idle
	timer_movement -= delta
	if timer_movement <= 0:
		if randf() < _cfg["walk_chance"]:
			var rand_angle = randf() * TAU
			direction_ofmovement = Vector2(cos(rand_angle), sin(rand_angle))
			timer_movement = randf_range(1.0, 2.5)
		else:
			direction_ofmovement = Vector2.ZERO
			timer_movement = randf_range(4.0, 10.0)

	velocity = direction_ofmovement * _cfg["speed"]
	move_and_slide()

	# Keep NPC within safe walkable map bounds
	var clamped = Vector2(
		clamp(global_position.x, 40.0, 950.0),
		clamp(global_position.y, 175.0, 890.0)
	)
	if clamped != global_position:
		global_position = clamped
		direction_ofmovement = Vector2.ZERO
		timer_movement = randf_range(2.0, 5.0)

	var sprite = $AnimatedSprite2D
	if direction_ofmovement.length() > 0.1:
		if direction_ofmovement.x < 0: sprite.flip_h = true
		elif direction_ofmovement.x > 0: sprite.flip_h = false
		if sprite.animation != "walk": sprite.play("walk")
	else:
		if sprite.animation != "default": sprite.play("default")

func show_lockdown_alert():
	var excl = $UI/Exclamation
	excl.visible = true
	excl.scale = Vector2(1.8, 1.8)
	excl.add_theme_color_override("font_color", Color(0.95, 0.05, 0.05))
	excl.add_theme_font_size_override("font_size", 80)

func hide_lockdown_alert():
	var excl = $UI/Exclamation
	# Always hide after lockdown clear - issue exclamation will re-show if needed
	excl.visible = false
	excl.scale = Vector2(1.0, 1.0)
	excl.add_theme_color_override("font_color", Color(1.0, 0.15, 0.10))
	excl.add_theme_font_size_override("font_size", 64)
	# Re-show small ! if NPC still has an active issue
	if has_issue and not escalated:
		excl.visible = true


func interact():
	if GameManager.lockdown_active:
		issue_clicked.emit(self)
		return
	if has_issue:
		issue_clicked.emit(self)

func lockdown_clear():
	if not GameManager.lockdown_active:
		return
	var root = get_tree().get_root()
	for child in root.get_children():
		for sub in child.get_children():
			if sub.name == "LockdownEvent":
				sub.notify_npc_cleared(self)
				return
			for subsub in sub.get_children():
				if subsub.name == "LockdownEvent":
					subsub.notify_npc_cleared(self)
					return

func create_issue(issue: CyberIssue):
	has_issue = true
	escalated = false
	current_issue = issue
	patience = _cfg["patience"]
	var excl = $UI/Exclamation
	excl.visible = true
	excl.scale = Vector2.ZERO
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(excl, "scale", Vector2(1, 1), 0.5)
	GameManager.incidents_changed.emit()

func wrong_answer():
	pass

func solve():
	var solved = current_issue
	if solved == null: return
	GameManager.issue_solved(solved.threat_level)
	GameManager.add_score(solved.threat_level * 100)
	has_issue = false
	current_issue = null
	patience = _cfg["patience"]
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()

func escalate():
	if escalated: return
	var failed = current_issue
	if failed == null: return
	escalated = true
	GameManager.issue_failed()
	GameManager.add_danger(failed.threat_level * 8.0)
	GameManager.add_score(-failed.threat_level * 100)
	# Record as wrong answer for Reflection Report (timed out = not answered correctly)
	var correct_ans = failed.answers[failed.correct_index]
	GameManager.record_wrong_answer(failed.issue_name, correct_ans, failed.explanation, failed.description)
	# Also write to scoreboard
	if "unsucessful_job_hist" in GameManager:
		var already = false
		for j in GameManager.unsucessful_job_hist:
			if j.get("name","") == failed.issue_name:
				already = true; break
		if not already:
			GameManager.unsucessful_job_hist.append({
				"name": failed.issue_name,
				"description": failed.description if "description" in failed else "",
				"answer": correct_ans,
				"explanation": failed.explanation
			})
	has_issue = false
	current_issue = null
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()
