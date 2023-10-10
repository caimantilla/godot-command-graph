Command graph plugin for Godot 4.2.dev6. Uses GraphEdit/GraphNode, with a basic implementation and way to add your own nodes. It's well-suited to RPGs.
I won't work on documentation for now as the version of Godot required is unstable, as is the plugin, and I'm busy making games. I'll add features as needed for my projects, or you can write an issue.

Still, basic usage:
Write your own class extending CommandDependencies,
Write a way to trigger execution.
Add paths to your custom command scripts in the project settings.

Examples:
Here's an example extension of CommandDependencies. This is how commands interact with the game.
```GDScript
@tool
class_name GameDependencies
extends CG_CommandDependencies


# Pass GameRoot as a dependency
var game_root = null
```

And here's my trigger node:
```GDScript
@tool
class_name CommandSequenceTrigger
extends EventSceneSubNode


signal finished()


@export var default_entrypoint_id: String = ""
@export var command_sequence: CG_CommandSequence = null

var runtime: CG_CommandRuntime = null


func execute(from_point: String = ""):
	if event == null or command_sequence == null:
		notify_finished()
		return
	
	if not command_sequence.has_command(from_point):
		from_point = default_entrypoint_id
	if not command_sequence.has_command(from_point):
		notify_finished()
		return
	
	var dependencies = _create_new_dependencies()
	runtime = CG_CommandRuntime.new(dependencies, command_sequence)
	runtime.name = "Command Runtime"
	runtime.finished.connect(clear, CONNECT_ONE_SHOT)
	runtime.finished.connect(notify_finished)
	add_child(runtime, true)
	runtime.execute(from_point)


func notify_finished() -> void:
	finished.emit()


func clear() -> void:
	if runtime != null:
		runtime.queue_free()
		runtime = null


func _create_new_dependencies():
	var dependencies = GameDependencies.new()
	dependencies.game_root = GameRoot # if GameRoot is an autoload
	return dependencies
```
There's an example for how to sequentially execute the commands that your game needs.

If you want to add your own nodes, you can work off of the existing nodes in the `res://addons/command_graph/base/` directory as examples.
Commands need both a resource (`CG_Command`) and an editor scene (`CG_CommandGraphNode`) implementation.
The basic idea is to connect the changed signals on the editor node to the `synchronize` method of the GraphNode, unbinding all of the signal's arguments.
For synchronizing between the editor node and resource, you need to override the `_initialize` and `_synchronize` virtual methods. These will only be called if appropriate. Be sure not to accidentally connect a node to `_synchronize` instead of `synchronize`, you'll probably crash Godot and mess up your commands.

One more thing: you'll probably notice by reading, but commands should never hold any state as members. You might be able to extend CommandState (I haven't tried this) but for my purposes binding what I need to Callables has been sufficient.
You cannot use `await` in the `_execute` method, either. You'll need to use signals and lambdas, or move into a different method. For example, many of my commands just make a state then call something like _exec_async(dependencies, state) which only finishes the state after all of its awaits are complete. `CG_CommandThread` expects a `CG_CommandState` to be returned immediately when it executes a command.
