package gui_sdl

import SDL "vendor:sdl2"

handle_events :: proc(self: ^GuiSDL) -> bool {
	event: SDL.Event
	for SDL.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			SDL.Log("Quitting UCIFrost UI")
			return false
		case .MOUSEBUTTONDOWN:
			if event.button.button == SDL.BUTTON_LEFT {
				mouse_x := event.button.x
				mouse_y := event.button.y
				square := position_to_square(self, mouse_x, mouse_y)
				noted := square_to_algebraic(square)
				SDL.Log("noted: %s", noted)
				// Highlight
			}
		}
	}
	return true
}
