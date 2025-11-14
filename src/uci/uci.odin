package uci

import "../process"
import "core:bufio"
import "core:fmt"
import "core:log"
import os "core:os/os2"
import "core:strings"

init :: proc(self: ^process.ProcessPipes) -> bool {
	message_engine(create_command("uci", ""), self)
	_ = read_from_engine(self, "uciok")

	message_engine(create_command("isready", ""), self)
	ready := read_from_engine(self, "readyok")

	if ready == "readyok" {
		log.info("UCI engine ready")
		return true
	}
	return false
}

create_command :: proc(cmd: string, args: string) -> string {
	if args == "" {
		return fmt.tprintf("%s\n", cmd)
	} else {
		return fmt.tprintf("%s %s\n", cmd, args)
	}
}

message_engine :: proc(msg: string, self: ^process.ProcessPipes) {
	message := transmute([]u8)msg
	log.debug("Messaging engine:", msg)
	_, err := os.write(self.stdin_write, message)
	if err != nil {
		log.errorf("Engine write error: ", err)
	}
}

read_from_engine :: proc(self: ^process.ProcessPipes, expected: string) -> string {
	r: bufio.Reader
	buffer: [2048]byte
	bufio.reader_init_with_buf(&r, self.stdout_read.stream, buffer[:])
	defer bufio.reader_destroy(&r)

	response_lines: [dynamic]string
	for {
		line, err := bufio.reader_read_string(&r, '\n', context.allocator)
		if err != nil {
			log.errorf("Failed reading from engine: ", err)
			break
		}
		trimmed := strings.trim_space(line)
		append(&response_lines, trimmed)
		if trimmed == expected {
			break
		}
	}

	return strings.join(response_lines[:], "\n", context.allocator)
}

position_fen :: proc(self: ^process.ProcessPipes, fen: string, moves_list: []string = {}) {
	log.info("position fen recieved: ", fen)
	moves_str := strings.join(moves_list, " ", context.allocator)
	log.info("moves_list: ", moves_str)
	args :=
		moves_str == "" ? fmt.tprintf("fen %s", fen) : fmt.tprintf("fen %s moves %s", fen, moves_str)
	message_engine(create_command("position", args), self)
}

go_search :: proc(self: ^process.ProcessPipes, depth: int = 10, movetime: int = 0) {
	args := ""
	if depth > 0 {
		args = fmt.tprintf("depth %d", depth)
	} else if movetime > 0 {
		args = fmt.tprintf("movetime %d", movetime)
	}
	message_engine(create_command("go", args), self)
}

read_bestmove :: proc(self: ^process.ProcessPipes) -> string {
	r: bufio.Reader
	buffer: [2048]byte
	bufio.reader_init_with_buf(&r, self.stdout_read.stream, buffer[:])
	defer bufio.reader_destroy(&r)

	bestmove := ""
	for {
		line, err := bufio.reader_read_string(&r, '\n', context.allocator)
		if err != nil {
			log.errorf("Failed reading from engine: ", err)
			break
		}

		trimmed := strings.trim_space(line)
		log.debug("Engine output:", trimmed)

		if strings.has_prefix(trimmed, "bestmove ") {
			parts := strings.split(trimmed, " ")
			defer delete(parts)
			if len(parts) >= 2 {
				bestmove = parts[1]
			}
			break
		}
	}
	return bestmove
}

quit :: proc(self: ^process.ProcessPipes) {
	log.info("Shutting down engine")
	message_engine(create_command("quit", ""), self)
}
