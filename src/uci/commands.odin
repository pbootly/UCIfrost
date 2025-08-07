package uci

UCI_READY := "readyok"

UCI_Command :: struct {
	UCI:        string,
	ISREADY:    string,
	UCINEWGAME: string,
	POSITION:   string,
	GO:         string,
	STOP:       string,
	QUIT:       string,
}

UCI := UCI_Command {
	UCI        = "uci",
	ISREADY    = "isready",
	UCINEWGAME = "ucinewgame",
	POSITION   = "position",
	GO         = "go",
	STOP       = "stop",
	QUIT       = "quit",
}

UCI_Response :: struct {
	UCIOK:    string,
	READYOK:  string,
	BESTMOVE: string,
}

UCI_Resp := UCI_Response {
	UCIOK    = "uciok",
	READYOK  = "readyok",
	BESTMOVE = "bestmove",
}
