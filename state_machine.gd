class_name StateMachine

extends Node

var current_state = null
var previous_state = null

var states = {}

@onready var parent = get_parent()

func _physics_process(delta: float):
    if current_state != null:
        _state_logic(delta)

        var transition = _get_transition(delta)
        if transition != null:
            set_state(transition)


func _state_logic(_delta: float):
    pass


func _get_transition(_delta: float):
    pass


func _enter_state(_old_state, _new_state):
    pass


func _exit_state(_old_state, _new_state):
    pass


func set_state(new_state):
    previous_state = current_state
    current_state = new_state

    if previous_state != null:
        _exit_state(previous_state, current_state)

    if current_state != null:
        _enter_state(previous_state, current_state)


func add_state(state):
    states[state] = states.size()

