extends Resource
class_name CyberIssue
# Visible to players issue name, Employee message for notification and question
@export var issue_name:String
@export_multiline var description:String #Mainly for dev to understand and used in reflection report for clarity
@export_multiline var employee_message:String

#  hidden from the player
@export var threat_level:int = 1
@export var urgency:float
@export var escalation:CyberEscalation
@export var score: int = 100

#Here, these are the Answers.
@export var correct_index:int
@export var answers:Array[String]

#Here, this is the Explanation after solving.
@export_multiline var explanation:String
