extends Node

signal init_ritual
signal walk_destination(target_position: Vector3)

signal spell_chanted(spell: String)
signal magic_word_pressed(word: String)
signal add_summon_power(power: int)
signal breach(position: Vector2)
signal portal_distracted(position: Vector2)

signal book_changed
signal change_notebook_page(page: String)
signal view_angle_changed(angle: float)
