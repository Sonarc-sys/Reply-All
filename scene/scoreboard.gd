
extends Control

# Removed strict typing (e.g., ": Label", "as Label") to prevent Godot from nullifying RichTextLabels
var job_list
var details_label
var explanation_label
var back_button

var failed_jobs: Array = []

func _ready() -> void:
	# find_child automatically searches the entire scene tree regardless of hierarchy
	job_list = find_child("JobList", true, false)
	back_button = find_child("BackButton", true, false)
	
	# Target the labels specifically inside DetailsPanel
	var details_panel = find_child("DetailsPanel", true, false)
	if details_panel:
		details_label = details_panel.find_child("Label", true, false)
		explanation_label = details_panel.find_child("ExplanationLabel", true, false)
	
	# Fallbacks just in case the labels aren't inside DetailsPanel
	if not explanation_label:
		explanation_label = find_child("ExplanationLabel", true, false)
	if not details_label:
		details_label = find_child("Label", true, false)

	# Final safety check
	if not job_list or not details_label or not explanation_label or not back_button:
		printerr("Scoreboard Error: Missing nodes! JobList: ", job_list, " | Details: ", details_label, " | Exp: ", explanation_label, " | Back: ", back_button)
		return

	job_list.item_selected.connect(_on_job_selected)
	back_button.pressed.connect(_on_back_button_pressed)
	
	load_failed_jobs()

func load_failed_jobs() -> void:
	job_list.clear()
	failed_jobs.clear()
	
	if GameManager and "unsucessful_job_hist" in GameManager:
		failed_jobs = GameManager.unsucessful_job_hist
		
	for job in failed_jobs:
		var job_name = job.get("name", "Unknown Issue")
		job_list.add_item(job_name)
		
	if failed_jobs.is_empty():
		job_list.add_item("No failed tasks recorded.")
		job_list.set_item_disabled(0, true)
		details_label.text = "Select a task to review its details."
		explanation_label.text = ""
	else:
		job_list.select(0)
		_on_job_selected(0)

func _on_job_selected(index: int) -> void:
	if index < 0 or index >= failed_jobs.size():
		return
		
	var job = failed_jobs[index]
	var desc = job.get("description", "No description available.")
	var ans = job.get("answer", "N/A")
	var exp = job.get("explanation", "No explanation provided.")
	
	details_label.text = "Description:\n%s\n\nYour Answer:\n%s" % [desc, ans]
	explanation_label.text = "Explanation:\n%s" % [exp]

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/GameOver.tscn")
