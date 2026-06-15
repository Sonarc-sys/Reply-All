extends Resource
class_name CyberIssue

@export var issue_name:String
@export_multiline var description:String
@export_multiline var employee_message:String

# Hidden from player
@export var threat_level:int = 1
@export var urgency:float
@export var escalation:CyberEscalation

# Answers
@export var correct_index:int
@export var answers:Array[String]

# Explanation after solving
@export_multiline var explanation:String
