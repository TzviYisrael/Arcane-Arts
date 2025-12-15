extends Node
@warning_ignore_start("unused_signal")
signal static_data_loaded
signal save_game
signal reload_save_file

signal start_ritual
signal summon_effect
signal change_ca_state(run: bool)
signal mage_look(pos: Vector3)
signal walk_destination(target_position: Vector3)

#Test
signal set_shader_textures(rt: Texture2D, lut: Texture3D, pt: Texture2D)
#test

signal spell_chanted(spell: String)
signal breach
signal summon_particles(target: Vector3, color: Color)
signal item_moved(item: Item)
signal add_to_inventory(item_name: String, amount: int)

signal book_changed
signal change_notebook_page(page: String)

signal rotate_camera(angle: float)
signal hide_wall(wall: Node3D)
@warning_ignore_restore("unused_signal")
