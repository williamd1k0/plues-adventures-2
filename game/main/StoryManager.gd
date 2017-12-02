extends Node

export(String, DIR) var panels_path
export(String) var first_panel
onready var input = get_node("UserInput")
onready var story = get_node("Story")
var choices_data
var achievement
var current_panel

func _ready():
	input.connect("command", self, "_on_UserInput_command")
	next_panel(first_panel)

func _on_UserInput_command(cmd):
	for action in choices_data[cmd]:
		if action == 'achievement':
			if not SaveData.has_achievement(choices_data[cmd][action]):
				SaveData.unlock_achievement(choices_data[cmd][action])
				input.type_info("%s: %s", tr('NEW_ENDING') + tr('ENDING_'+choices_data[cmd][action]))
				yield(input, 'text_type')
		elif action == 'script':
			choices_data[cmd][action].execute(self)
		elif action == 'checkpoint':
			SaveData.add_save_point(current_panel)
	next_panel(choices_data[cmd]['goto-id'])

func _on_StoryPanel_needs_input(choices):
	choices_data = choices
	input.wait_command(choices.keys())

func next_panel(id):
	if story.get_child_count() > 0:
		for child in story.get_children():
			story.remove_child(child)
	current_panel = id
	var path = panels_path
	if id.begins_with('panel'):
		path += '/story'
	var panel = load(path.plus_file('%s.tscn' % id)).instance()
	panel.connect('needs_input', self, '_on_StoryPanel_needs_input')
	story.add_child(panel)
	panel.start()
