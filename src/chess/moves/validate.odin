package validate

import "../../process"
import "../../uci"
import "base:runtime"
import "core:log"

import "core:strings"

validate_moves_for_piece :: proc(
	src_square: string,
	position_cmd: string,
	engine: ^process.ProcessPipes,
) -> []string {
	current_position_cmd := uci.create_command(uci.UCI.POSITION, position_cmd)
	uci.message_engine(current_position_cmd, engine)

	perft_cmd := uci.create_command(uci.UCI.GO, " perft 1")
	uci.message_engine(perft_cmd, engine)

	response := uci.read_from_engine(engine, "Nodes searched")

	lines := strings.split(response, "\n")

	moves: [dynamic]string

	for i in 0 ..< len(lines) {
		line := strings.trim(lines[i], " \t\n\r")
		if len(line) == 0 {
			continue
		}

		if strings.has_prefix(line, src_square) {
			parts := strings.split(line, ":")
			if len(parts) > 0 {
				move_str := parts[0]
				append(&moves, move_str)
			}
		}
	}

	return moves[:]
}
