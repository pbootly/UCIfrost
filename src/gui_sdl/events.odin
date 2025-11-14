package gui_sdl

import "../chess/moves"
import "../process"
import "../uci"
import "core:log"
import "core:strings"
import SDL "vendor:sdl2"

Move :: struct {
	from:     string,
	to:       string,
	has_from: bool,
}

// Global state for move selection
move: Move = Move{}
selected_square: string = ""
valid_moves: []string = {} // Store valid moves for the selected piece

get_valid_destination_squares :: proc() -> []string {
	destinations: [dynamic]string
	for move in valid_moves {
		if len(move) >= 4 {
			dest_square := move[2:4]
			append(&destinations, dest_square)
		}
	}
	return destinations[:]
}

handle_events :: proc(self: ^GuiSDL, board_fen: string, engine: ^process.ProcessPipes) -> bool {
	event: SDL.Event
	for SDL.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			return false

		case .MOUSEBUTTONDOWN:
			if event.button.button == SDL.BUTTON_LEFT {
				mouse_x := event.button.x
				mouse_y := event.button.y

				square := position_to_square(self, mouse_x, mouse_y)
				algebraic := square_to_algebraic(square)

				if !move.has_from {
					move.from = algebraic
					move.has_from = true
					selected_square = algebraic
					log.info("Selected source square: ", algebraic)
					return true
				} else {
					move.to = algebraic
					log.info("Selected destination square: ", algebraic)

					if move.from == move.to {
						move.has_from = false
						selected_square = ""
						return true
					}

					from_sq := moves.algebraic_to_square(move.from)
					to_sq := moves.algebraic_to_square(move.to)

					if from_sq == -1 || to_sq == -1 {
						move.has_from = false
						selected_square = ""
						return true
					}

					chess_move := moves.Move {
						from_square = from_sq,
						to_square   = to_sq,
						promotion   = "",
					}

					uci_move_str := moves.move_to_uci(chess_move)
					log.info("UCI move string generated: ", uci_move_str)
					log.debugf("from_sq=%d to_sq=%d", from_sq, to_sq)
					if uci_move_str != "" {
						moves_str: [dynamic]string
						append(&moves_str, uci_move_str)
						joined := strings.join(moves_str[:], " ", context.allocator)
						log.info("Sending moves_list: ", joined)

						uci.position_fen(engine, board_fen, moves_str[:])
					}

					// Reset selection
					move.has_from = false
					selected_square = ""
				}
			}
		}
	}

	return true
}
