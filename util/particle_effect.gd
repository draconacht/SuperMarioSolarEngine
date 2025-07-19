@tool
class_name ParticleEffect
extends Resource

## Associated scene of this particle effect.
@export var particle_scene: PackedScene

## Position offset for this particle effect.
@export var particle_offset := Vector2.ZERO

## Scale for this particle effect.
@export var particle_scale := Vector2.ONE

## Amount of frames between continious loop particles.
@export var loop_delay: int = 0
var timer: int = loop_delay

@export_tool_button("Preview Particle", "Play") var action_pressed = _preview_pressed


## Emit the particle at a specific node.[br]
## [param offset_overwrite] is useful if you want to use logic defined offsets instead.[br]
## [param scale_overwrite] is useful if you want to use logic defined scales instead.
func emit_at(node: Node, offset_overwrite := Vector2.ZERO, scale_overwrite := Vector2.ONE):
	if timer > 0:
		timer = max(timer - 1, 0)
	else:
		timer = loop_delay

		var particle: Node = particle_scene.instantiate()

		if offset_overwrite != Vector2.ZERO:
			particle.position = offset_overwrite
		else:
			particle.position = particle_offset

		if scale_overwrite != Vector2.ONE:
			particle.scale = scale_overwrite
		else:
			particle.scale = particle_scale

		if particle is CPUParticles2D or particle is GPUParticles2D:
			particle.emitting = true
			particle.connect(&"finished", particle.queue_free)
		elif particle is Node2D:
			var child_count: int = particle.get_child_count()

			particle.set_meta(&"counter", 0)

			for child in particle.get_children():
				child.emitting = true

				child.connect(&"finished", _free_particle_group.bind(particle, child_count, &"counter"))
		else:
			assert(false, "Unsupported type of particle: " + particle.get_class())

		node.add_child(particle)


## Deletes a particle group ([Node2D]) when all its children
## ([CPUParticles2D] or [GPUParticles2D]) are finished playing.
func _free_particle_group(group_node: Node, particle_amt: int, counter_meta: StringName):
	group_node.set_meta(counter_meta, group_node.get_meta(counter_meta) + 1)

	if particle_amt == group_node.get_meta(counter_meta):
		group_node.queue_free()


func _preview_pressed():
	#if not resource_local_to_scene:
	#printerr("Cannot preview a particle if local to scene is disabled. Check the variable under Resource -> resource_local_to_scene")
	#return

	emit_at(get_local_scene(), particle_offset)
