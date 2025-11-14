package moves

import "../../process"
import "base:runtime"
import "core:log"
import "core:strings"

validate_moves_for_piece :: proc(
	src_square: string,
	position_cmd: string,
	engine: ^process.ProcessPipes,
) -> []string {
	moves: [dynamic]string
	return moves[:]
}
