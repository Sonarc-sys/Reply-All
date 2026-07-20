extends Control

var current_employee
var correct_button = 0
var current_issue

@onready var question_label = $Panel/Vbox/Question
@onready var explanation_label = $Panel/Vbox/ExplanationLabel 

func open(employee):
	current_employee = employee
	visible = true
	explanation_label.visible = false 
	current_issue = employee.current_issue
	
	question_label.text = current_issue.description

	var buttons = [$Panel/Vbox/Option1, $Panel/Vbox/Option2, $Panel/Vbox/Option3]
	var indices = [0, 1, 2]
	indices.shuffle() 

	for i in range(3):
		buttons[i].text = current_issue.answers[indices[i]]
		if indices[i] == current_issue.correct_index:
			correct_button = i

func check_answer(button):
	if button == correct_button:
		correct_answer()
	else:
		wrong_answer()

func correct_answer():
	print("Correct!")
	current_employee.solve()
	visible = false

func wrong_answer():
	current_employee.escalate()
	
	visible = false

func _on_option_1_pressed():
	check_answer(0)

func _on_option_2_pressed():
	check_answer(1)

func _on_option_3_pressed():
	check_answer(2)
