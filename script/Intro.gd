extends Control

@onready var label    = $CenterContainer/VBox/LineLabel
@onready var skip_btn = $SkipButton

# Lines of the intro cutscene  -  typewriter style
const LINES = [
	"7:58 AM. Monday.",
	"The coffee machine is broken.",
	"There are 47 unread tickets.",
	"And someone already clicked a suspicious link.",
	"",
	"Welcome to your first day as the Only IT Guy.",
	"",
	"Grab your coffee, kid.",
	"Good luck.",
]

var line_index   = 0
var char_index   = 0
var full_text    = ""
var typing       = false
var line_timer   = 0.0
const CHAR_DELAY = 0.04  # seconds per character
const LINE_PAUSE = 1.2   # pause between lines

func _ready():
	label.text = ""
	_start_line()

func _start_line():
	if line_index >= LINES.size():
		_go_to_game()
		return
	full_text  = LINES[line_index]
	char_index = 0
	label.text = ""
	typing     = true
	line_timer = 0.0

func _process(delta):
	if not typing:
		line_timer -= delta
		if line_timer <= 0.0:
			line_index += 1
			_start_line()
		return

	line_timer += delta
	if line_timer >= CHAR_DELAY:
		line_timer = 0.0
		if char_index < full_text.length():
			char_index += 1
			label.text = full_text.substr(0, char_index)
		else:
			typing     = false
			line_timer = LINE_PAUSE

func _on_skip_pressed():
	_go_to_game()

func _go_to_game():
	get_tree().change_scene_to_file("res://scene/office.tscn")
