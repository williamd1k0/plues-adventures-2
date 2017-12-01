extends Label

enum {
	A_CHECKPOINT=1<<0,
	A_ACHIEVEMENT=1<<1,
	A_SCRIPT=1<<2
}

export(String) var choice_id = ""
export(String) var goto_id = ""
export(int, "Choice ID", "Label text", "First character") var id_type = 0
export(int, FLAGS, "Checkpoint", "Achievement", "Script") var actions = 0
export(String) var achievement_id
export(Script) var custom_script
export(bool) var selectable = true

func _ready():
	set_hidden(get_choice_id() in [null, ""] or not selectable)

func get_choice_id():
	if id_type == 1:
		return get_text().strip_edges()
	elif id_type == 2:
		return get_text().strip_edges()[0]
	return tr(choice_id)

func get_data():
	var data = {
		"choice-id": get_choice_id(),
		"goto-id": goto_id
	}
	if actions & A_CHECKPOINT:
		data["checkpoint"] = goto_id
	if actions & A_ACHIEVEMENT:
		data["achievement"] = achievement_id
	if actions & A_SCRIPT:
		data["script"] = custom_script
	return data
	