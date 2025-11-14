#+feature dynamic-literals
package moves

import "core:fmt"
import "core:strconv"
import "core:strings"

// Move representation in UCI format (e.g., "e2e4", "e7e8q")
Move :: struct {
	from_square: int,    // 0-63 square index
	to_square:   int,    // 0-63 square index
	promotion:   string, // "q", "r", "b", "n" or "" for no promotion
}

// Convert algebraic notation (e.g., "e2") to square index (0-63)
algebraic_to_square :: proc(algebraic: string) -> int {
	if len(algebraic) != 2 {
		return -1
	}

	file := int(algebraic[0] - 'a')  // a=0, b=1, ..., h=7
	rank := int(algebraic[1] - '1')  // 1=0, 2=1, ..., 8=7

	if file < 0 || file > 7 || rank < 0 || rank > 7 {
		return -1
	}

	return rank * 8 + file
}

// Convert square index (0-63) to algebraic notation (e.g., "e2")
square_to_algebraic :: proc(square: int) -> string {
	if square < 0 || square > 63 {
		return ""
	}

	file := square % 8
	rank := square / 8

	file_char := byte('a' + file)
	rank_char := byte('1' + rank)

	return string([]byte{file_char, rank_char})
}

// Parse UCI move string (e.g., "e2e4", "e7e8q") to Move struct
parse_uci_move :: proc(uci_move: string) -> (Move, bool) {
	if len(uci_move) < 4 || len(uci_move) > 5 {
		return {}, false
	}

	from_algebraic := uci_move[0:2]
	to_algebraic := uci_move[2:4]

	from_square := algebraic_to_square(from_algebraic)
	to_square := algebraic_to_square(to_algebraic)

	if from_square == -1 || to_square == -1 {
		return {}, false
	}

	promotion := ""
	if len(uci_move) == 5 {
		promotion = uci_move[4:5]
		// Validate promotion piece
		if promotion != "q" && promotion != "r" && promotion != "b" && promotion != "n" {
			return {}, false
		}
	}

	return Move{
		from_square = from_square,
		to_square = to_square,
		promotion = promotion,
	}, true
}

// Convert Move struct to UCI move string
move_to_uci :: proc(move: Move) -> string {
    from_algebraic := square_to_algebraic(move.from_square)
    to_algebraic := square_to_algebraic(move.to_square)

    if from_algebraic == "" || to_algebraic == "" {
        return ""
    }

    uci_move := strings.concatenate({from_algebraic, to_algebraic})

    if move.promotion != "" {
        uci_move = strings.concatenate({uci_move, move.promotion})
    }

    return uci_move
}

// move_to_uci :: proc(move: Move) -> string {
//     from_algebraic := square_to_algebraic(move.from_square)
//     to_algebraic := square_to_algebraic(move.to_square)
//
//     if from_algebraic == "" || to_algebraic == "" {
//         return ""
//     }
//
//     uci_parts: [dynamic]string
//     append(&uci_parts, from_algebraic)
//     append(&uci_parts, to_algebraic)
//
//     uci_move := strings.join(uci_parts[:], "", context.allocator) // join without separator
//
//     if move.promotion != "" {
//         uci_move = strings.join([dynamic]string{uci_move, move.promotion}[:], "", context.allocator)
//     }
//
//     return uci_move
// }

// Parse a list of UCI moves (e.g., "e2e4 e7e5 g1f3")
parse_uci_moves :: proc(moves_string: string) -> [dynamic]Move {
	moves := make([dynamic]Move)

	if strings.trim_space(moves_string) == "" {
		return moves
	}

	move_strings := strings.split(moves_string, " ")
	defer delete(move_strings)

	for move_str in move_strings {
		move_str_trimmed := strings.trim_space(move_str)
		if move_str_trimmed != "" {
			if move, ok := parse_uci_move(move_str_trimmed); ok {
				append(&moves, move)
			}
		}
	}

	return moves
}

// Convert list of moves to UCI format string
moves_to_uci :: proc(moves: []Move) -> string {
	if len(moves) == 0 {
		return ""
	}

	// Safety check for nil slice
	if moves == nil {
		return ""
	}

	uci_moves := make([dynamic]string)
	defer delete(uci_moves)

	for move, i in moves {
		// Additional validation
		if move.from_square < 0 || move.from_square > 63 ||
		   move.to_square < 0 || move.to_square > 63 {
			// Skip invalid moves instead of crashing
			continue
		}

		uci_move := move_to_uci(move)
		if uci_move != "" {
			append(&uci_moves, uci_move)
		}
	}

	return strings.join(uci_moves[:], " ")
}

