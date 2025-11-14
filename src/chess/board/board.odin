package board

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Board :: struct {
	size:            int,
	pieces:          [64]string,
	// Game state for FEN generation
	active_color:    Color,
	castling_rights: CastlingRights,
	en_passant:      int, // square index, -1 for none
	halfmove_clock:  int, // moves since last pawn move or capture
	fullmove_number: int, // increments after black's move
}

Color :: enum {
	White,
	Black,
}

CastlingRights :: struct {
	white_kingside:  bool,
	white_queenside: bool,
	black_kingside:  bool,
	black_queenside: bool,
}

Bitboard :: struct {
	white_pieces:  u64,
	black_pieces:  u64,
	white_pawns:   u64,
	black_pawns:   u64,
	white_rooks:   u64,
	black_rooks:   u64,
	white_knights: u64,
	black_knights: u64,
	white_bishops: u64,
	black_bishops: u64,
	white_queen:   u64,
	black_queen:   u64,
	white_king:    u64,
	black_king:    u64,
}


init_board :: proc(board: ^Board) {
	bb := Bitboard {
		white_pawns   = 0x000000000000FF00,
		white_rooks   = 0x0000000000000081,
		white_knights = 0x0000000000000042,
		white_bishops = 0x0000000000000024,
		white_queen   = 0x0000000000000008,
		white_king    = 0x0000000000000010,
		black_pawns   = 0x00FF000000000000,
		black_rooks   = 0x8100000000000000,
		black_knights = 0x4200000000000000,
		black_bishops = 0x2400000000000000,
		black_queen   = 0x0800000000000000,
		black_king    = 0x1000000000000000,
	}

	// Compute aggregate pieces bitboards
	bb.white_pieces =
		bb.white_pawns |
		bb.white_rooks |
		bb.white_knights |
		bb.white_bishops |
		bb.white_queen |
		bb.white_king
	bb.black_pieces =
		bb.black_pawns |
		bb.black_rooks |
		bb.black_knights |
		bb.black_bishops |
		bb.black_queen |
		bb.black_king

	for sq in 0 ..< 64 {
		board.pieces[sq] = get_piece_name_on_square(&bb, sq)
	}

	// Initialize game state to starting position
	board.active_color = Color.White
	board.castling_rights = CastlingRights {
		white_kingside  = true,
		white_queenside = true,
		black_kingside  = true,
		black_queenside = true,
	}
	board.en_passant = -1 // No en passant square
	board.halfmove_clock = 0
	board.fullmove_number = 1
}

get_piece_name_on_square :: proc(bitboard: ^Bitboard, square: int) -> string {
	mask := u64(1) << u64(square)

	if bitboard.white_pawns & mask != 0 {
		return "w_pawn"
	} else if bitboard.white_rooks & mask != 0 {
		return "w_rook"
	} else if bitboard.white_knights & mask != 0 {
		return "w_knight"
	} else if bitboard.white_bishops & mask != 0 {
		return "w_bishop"
	} else if bitboard.white_queen & mask != 0 {
		return "w_queen"
	} else if bitboard.white_king & mask != 0 {
		return "w_king"
	} else if bitboard.black_pawns & mask != 0 {
		return "b_pawn"
	} else if bitboard.black_rooks & mask != 0 {
		return "b_rook"
	} else if bitboard.black_knights & mask != 0 {
		return "b_knight"
	} else if bitboard.black_bishops & mask != 0 {
		return "b_bishop"
	} else if bitboard.black_queen & mask != 0 {
		return "b_queen"
	} else if bitboard.black_king & mask != 0 {
		return "b_king"
	}

	return ""
}

piece_to_fen_letter :: proc(piece_name: string) -> rune {
	letter: rune

	switch piece_name {
	case "w_pawn":
		letter = 'P'
	case "w_knight":
		letter = 'N'
	case "w_bishop":
		letter = 'B'
	case "w_rook":
		letter = 'R'
	case "w_queen":
		letter = 'Q'
	case "w_king":
		letter = 'K'

	case "b_pawn":
		letter = 'p'
	case "b_knight":
		letter = 'n'
	case "b_bishop":
		letter = 'b'
	case "b_rook":
		letter = 'r'
	case "b_queen":
		letter = 'q'
	case "b_king":
		letter = 'k'

	case:
		letter = '1'
	}

	return letter
}


board_to_fen :: proc(b: ^Board) -> string {
	fen_parts: [dynamic]string
	defer delete(fen_parts)

	// Generate piece placement (ranks 8 to 1, from a-h)
	for rank in 0 ..< 8 {
		rank_str: [dynamic]rune
		defer delete(rank_str)

		empty_count := 0

		for file in 0 ..< 8 {
			// Chess board is indexed from rank 8 (top) to rank 1 (bottom)
			// But our array goes from 0-63, so we need to convert
			square := (7 - rank) * 8 + file
			piece := b.pieces[square]

			if piece == "" {
				empty_count += 1
			} else {
				// Add empty squares count if any
				if empty_count > 0 {
					append(&rank_str, rune('0' + empty_count))
					empty_count = 0
				}
				// Add piece letter
				append(&rank_str, piece_to_fen_letter(piece))
			}
		}

		// Add remaining empty squares at end of rank
		if empty_count > 0 {
			append(&rank_str, rune('0' + empty_count))
		}

		rank_string := utf8.runes_to_string(rank_str[:])
		append(&fen_parts, rank_string)
	}

	// Join ranks with '/'
	piece_placement := strings.join(fen_parts[:], "/")

	// Use actual board state for FEN components
	active_color := b.active_color == Color.White ? "w" : "b"

	// Build castling rights string
	castling_str: [dynamic]rune
	defer delete(castling_str)
	if b.castling_rights.white_kingside {
		append(&castling_str, 'K')
	}
	if b.castling_rights.white_queenside {
		append(&castling_str, 'Q')
	}
	if b.castling_rights.black_kingside {
		append(&castling_str, 'k')
	}
	if b.castling_rights.black_queenside {
		append(&castling_str, 'q')
	}
	castling_rights := len(castling_str) > 0 ? utf8.runes_to_string(castling_str[:]) : "-"

	// En passant square
	en_passant := b.en_passant == -1 ? "-" : square_to_algebraic(b.en_passant)

	// Move counters
	halfmove_clock := fmt.tprintf("%d", b.halfmove_clock)
	fullmove_number := fmt.tprintf("%d", b.fullmove_number)

	// Combine all FEN components
	fen_components := [6]string {
		piece_placement,
		active_color,
		castling_rights,
		en_passant,
		halfmove_clock,
		fullmove_number,
	}

	return strings.join(fen_components[:], " ")
}

// Helper function to update aggregate bitboards after piece changes
update_aggregate_bitboards :: proc(bb: ^Bitboard) {
	bb.white_pieces =
		bb.white_pawns |
		bb.white_rooks |
		bb.white_knights |
		bb.white_bishops |
		bb.white_queen |
		bb.white_king
	bb.black_pieces =
		bb.black_pawns |
		bb.black_rooks |
		bb.black_knights |
		bb.black_bishops |
		bb.black_queen |
		bb.black_king
}

// Helper function to convert square index to algebraic notation for FEN
square_to_algebraic :: proc(square: int) -> string {
	if square < 0 || square > 63 {
		return ""
	}

	file := square % 8
	rank := square / 8

	file_char := byte('a' + file)
	rank_char := byte('1' + rank)

	return fmt.tprintf("%c%c", file_char, rank_char)
}
