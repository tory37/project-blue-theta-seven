class_name StateMachine

var current_state: State = null

func change_state(next: State) -> void:
	if current_state:
		current_state.exit()
		
	current_state = next
	current_state.enter()