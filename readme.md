Command graph plugin for Godot 4.1. Uses GraphEdit/GraphNode, with a basic implementation and way to add your own nodes. It's well-suited to RPGs.
I won't work on documentation for now, as any editor nodes you make will probably be [incompatible with a future version of Godot 4.](https://github.com/godotengine/godot/pull/67152) Also, I'm busy actually making a game.

Still, basic usage:
Write your own class extending CommandDependencies,
Write a way to trigger execution.
Add paths to your custom command scripts in the project settings.

Examples:
Here's my extension of CommandDependencies. This is how commands interact with the game.
```GDScript
@tool
class_name JadeCommandDependencies
extends CommandDependencies


var event: EventScene = null
var field: Field = null
var battle: Battle = null
var chat: Chat = null
```

And here's my trigger node:
```GDScript
@tool
class_name CommandSequenceTrigger
extends EventSceneSubNode


signal finished()


@export var default_entrypoint_id: String = ""
@export var command_sequence: CommandSequence = null

var runtime: CommandRuntime = null


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
	runtime = CommandRuntime.new(dependencies, command_sequence)
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
	var dependencies = JadeCommandDependencies.new()
	dependencies.event = event
	dependencies.chat = event.chat
	dependencies.field = event.field
	dependencies.battle = event.battle
	return dependencies
```
With that, I can sequentially execute whatever commands my game needs.

If you want to add your own nodes, you can work off of the existing nodes in the `res://addons/command_graph/base/` directory as examples.
Nodes need both a resource and in-editor implementation.
The basic idea is to connect the changed signals on the editor node to the `synchronize` method of the GraphNode.
For synchronizing between the editor node and resource, you need to use the `_initialize` and `_synchronize` virtual methods. These will only be called if appropriate. Be sure not to accidentally connect a node to `_synchronize` instead of `synchronize`, you'll probably crash Godot and mess up your commands.

One more thing: you'll probably notice by reading, but commands should never hold any state as members. You might be able to extend CommandState (I haven't tried this) but for my purposes binding what I need to Callables has been sufficient.
You cannot use `await` either. You'll need to use signals, or at least move into a different method. `CommandThread` expects a `CommandState` to be returned immediately when it executes a command.
