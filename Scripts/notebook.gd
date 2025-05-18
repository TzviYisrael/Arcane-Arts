extends Control

@onready var spell_container: VBoxContainer = $Control/spell_container
@onready var title: Label = $Control/title
@onready var control: Control = $Control

enum MODES {SUMMON, SUMMON_SPELLS, ROOM_SPELLS, CHALKBOARD, FLOOR, STUDY}

var pages: Dictionary = {
	MODES.SUMMON : ["zamen shor", "zamen tzfardio", "zamen mazzik", "",
					 "kill", "release", "clear"],
	MODES.SUMMON_SPELLS : [],
	MODES.ROOM_SPELLS : [],
	MODES.CHALKBOARD : ["reset"],
	MODES.FLOOR: ["reset", "save"],
	MODES.STUDY: []
	}

@export_enum("summon", "summon_spells",
 "room_spells", "chalkboard", "floor") var page: int
var root_of_parent: Node

func _ready() -> void:
	set_page(page)

func clear_page() -> void:
	for n in spell_container.get_children():
		spell_container.remove_child(n)
		n.queue_free()
	
func set_page(p: int) -> void:
	clear_page()
	title.text = str(MODES.keys()[p]).to_lower()
	var icon := preload("res://Assets/textures/joystick_center.png")
	for spl: String in pages[p]:
		if spl != "":
			var button: = Button.new()
			button.name = spl
			button.text = spl
			button.icon = icon
			button.expand_icon = true
			button.flat = true
			button.add_theme_font_size_override("font_size", 30)
			button.add_theme_color_override("font_color", Color.BLACK)
			button.connect("pressed", 
				get_tree().get_current_scene()._on_spell_chanted.bind(spl))
			spell_container.add_child(button)
		else:
			var sep := HSeparator.new()
			sep.add_theme_constant_override("separation", 20)
			spell_container.add_child(sep)

func _on_button_toggled(toggled_on: bool) -> void:
	control.visible = toggled_on
	control.mouse_filter = Control.MOUSE_FILTER_STOP \
	 if toggled_on else Control.MOUSE_FILTER_PASS
