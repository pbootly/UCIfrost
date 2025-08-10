package board

Board :: struct {
	size:   int,
	pieces: [64]string,
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
    bb := Bitboard{
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

    for sq in 0..<64 {
        board.pieces[sq] = get_piece_name_on_square(&bb, sq)
    }
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
