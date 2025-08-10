package gui_sdl

import "../chess/moves"
import "../process"
import "core:log"
import SDL "vendor:sdl2"

Move :: struct {
	from:     string,
	to:       string,
	has_from: bool,
}

move: Move = Move{}

handle_events :: proc(self: ^GuiSDL, board_fen: string, engine: ^process.ProcessPipes) -> bool {
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

				if !move.has_from {
					move.from = noted
					move.has_from = true
					SDL.Log("Selected source square: %s", noted)
					valid_moves := moves.validate_moves_for_piece(move.from, board_fen, engine)
					for m in valid_moves {
						log.info("Valid move: %s", m)
					}

				} else {
					move.to = noted
					SDL.Log("Selected destination square: %s", noted)

					move.has_from = false
					// Validate move
					// If valid update board
					// Tell engine
				}
			}
		}
	}
	return true
}
