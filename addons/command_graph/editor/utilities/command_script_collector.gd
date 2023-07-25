@tool
extends RefCounted


const COMMAND_FOLDERS_PROJECT_SETTING: String = "command_graph/filesystem/command_folders"
const COMMAND_FOLDERS_DEFAULT_VALUE: PackedStringArray = [ "res://addons/command_graph/base/commands/" ]






## Generates a dictionary of categorized script name/path references.
static func get_command_script_categorized_map( filter_to_instantiable: bool, p_command_map: Dictionary = {} ) -> Dictionary:
	
	# Clear it before writing the new values!!
	p_command_map.clear()
	
	var command_scripts := get_command_scripts()
	
	for script in command_scripts:
		
		# Skip over scripts that can't be instantiated, or ones which lack an editable scene
		if filter_to_instantiable:
			if not script.editor_get_instantiable() \
			or not ResourceLoader.exists( script.editor_get_scene_path(), "PackedScene" ):
				continue
		
		var command_name = script.editor_get_name()
		var command_category = script.editor_get_category()
		
		_create_category_if_it_doesnt_exist( command_category, p_command_map )
		
		# Get to the right category
		var destination_category_dictionary: Dictionary = p_command_map
		for category_name in command_category:
			destination_category_dictionary = destination_category_dictionary[category_name]
		
		destination_category_dictionary[command_name] = script.resource_path
	
	return p_command_map



## Ensures that the category/subcategory exists.
static func _create_category_if_it_doesnt_exist( p_category: PackedStringArray, p_command_map: Dictionary ) -> void:
	
	var current_category_dictionary: Dictionary = p_command_map
	
	for category_name in p_category:
		
		if not current_category_dictionary.has( category_name ):
			current_category_dictionary[category_name] = {}
		
		current_category_dictionary = current_category_dictionary[category_name]



static func get_command_scripts() -> Array [Script]:
	
	var scripts: Dictionary = {}
	var folders: PackedStringArray = get_command_folders()
	
	# Add subfolder recursion later, I'm lazy rn
	for folder_path in folders:
		
		var dir := DirAccess.open( folder_path )
		if is_instance_valid( dir ):
			
			dir.list_dir_begin()
			
			var next_file: String = dir.get_next()
			while not next_file.is_empty():
				var next_file_path: String = folder_path.path_join( next_file )
				# Only register script resources!!
				if ResourceLoader.exists( next_file_path, "Script" ):
					scripts[next_file_path] = true
				next_file = dir.get_next()
			
			dir.list_dir_end()
	
	
	var script_list: Array [Script] = []
	# Filter the files to the ones that are command scripts
	for script_path in scripts.keys():
		
		var script: Script = _get_command_script_from_path( script_path )
		
		if is_instance_valid( script ):
			script_list.append( script )
	
	return script_list


static func get_command_folders() -> PackedStringArray:
	
	if Engine.is_editor_hint():
		if not ProjectSettings.has_setting( COMMAND_FOLDERS_PROJECT_SETTING ):
			ProjectSettings.set_setting( COMMAND_FOLDERS_PROJECT_SETTING, COMMAND_FOLDERS_DEFAULT_VALUE )
			ProjectSettings.set_initial_value( COMMAND_FOLDERS_PROJECT_SETTING, COMMAND_FOLDERS_DEFAULT_VALUE )
			ProjectSettings.save()
	
	var command_folders: Variant = ProjectSettings.get_setting( COMMAND_FOLDERS_PROJECT_SETTING, COMMAND_FOLDERS_DEFAULT_VALUE )
	
	if typeof( command_folders ) == TYPE_PACKED_STRING_ARRAY:
		return command_folders
	else:
		return COMMAND_FOLDERS_DEFAULT_VALUE


static func _get_command_script_from_path( script_path: String ) -> Script:
	
	if not ResourceLoader.exists( script_path, "Script" ):
		return null
	
	var script := ResourceLoader.load( script_path, "Script" ) as Script
	if not is_instance_valid( script ):
		return null
	
	var current_base_script = script
	while is_instance_valid( current_base_script ):
		
		if current_base_script == CG_Command:
			
			return script
		
		# Progress to the next super class
		current_base_script = current_base_script.get_base_script()
	
	return null
