extends Node

signal start_ritual
signal change_ca_state(run: bool)
signal mage_look(pos: Vector3)
signal walk_destination(target_position: Vector3)

signal spell_chanted(spell: String)
signal breach
signal item_moved(item: Item)

signal book_changed
signal change_notebook_page(page: String)
signal view_angle_changed(angle: float)
