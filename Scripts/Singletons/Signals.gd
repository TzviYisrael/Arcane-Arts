extends Node
signal static_data_loaded
signal save_game
signal reload_save_file

signal start_ritual
signal summon_effect
signal change_ca_state(run: bool)
signal mage_look(pos: Vector3)
signal walk_destination(target_position: Vector3)

signal spell_chanted(spell: String)
signal breach
signal summon_particles(target: Vector3, color: Color)
signal item_moved(item: Item)
signal add_to_inventory(item_name: String, amount: int)

signal book_changed
signal change_notebook_page(page: String)

signal rotate_camera(angle: float)
signal hide_wall(wall: Node3D)
