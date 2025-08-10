package pieces

// In Odin, global declarations must be initialized with single fixed-size 
// aggregate literals because multi-value or slice literals aren’t allowed at file scope.
piece_names_array: [12]string = {
	"w_pawn",
	"w_rook",
	"w_knight",
	"w_bishop",
	"w_queen",
	"w_king",
	"b_pawn",
	"b_rook",
	"b_knight",
	"b_bishop",
	"b_queen",
	"b_king",
}

piece_names: []string = piece_names_array[:]
