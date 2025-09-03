extends Node

signal init_ritual
signal change_ca_state(run: bool)
signal walk_destination(target_position: Vector3)

signal spell_chanted(spell: String)
signal breach

signal book_changed
signal change_notebook_page(page: String)
signal view_angle_changed(angle: float)
