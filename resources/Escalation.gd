extends Resource
class_name CyberEscalation

@export var escalation_name:String
@export_multiline var description:String

# How bad it gets
@export var severity:int = 1

# How fast it grows
@export var escalation_rate:float = 1.0

@export_multiline var consequence_text:String
