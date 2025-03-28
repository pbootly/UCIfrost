package uci 

import os "core:os/os2"
import "core:log"
import "core:bufio"
import "core:strings"
import "core:time"
import "core:fmt"
import "../process"

init :: proc(self: ^process.ProcessPipes) -> bool{
    message_engine(create_command(UCI.UCI, ""), self)
    // TODO: handle engine options
    uci := read_from_engine(self, UCI_Resp.UCIOK)
    message_engine(create_command(UCI.ISREADY, ""), self)
    ready := read_from_engine(self, UCI_Resp.READYOK)
    if ready == UCI_READY {
        log.info("Stockfish ready")
        return true
    }
    return false
}

create_command :: proc(cmd: string, args: string) -> string {
    command := [?]string {cmd, args, "\n"}
    return strings.concatenate(command [:])
}

message_engine :: proc(msg: string, self: ^process.ProcessPipes) {
    message := transmute([]u8)msg
    log.debug("Messaging engine:", msg)
    _, err := os.write(self.stdin_write, message)
    if err != nil {
        log.errorf("Process write error: ", err)
    }
}

read_from_engine :: proc(self: ^process.ProcessPipes, expected: string) -> string {
    r: bufio.Reader
    buffer: [1024]byte
    bufio.reader_init_with_buf(&r, self.stdout_read.stream, buffer[:])
    defer bufio.reader_destroy(&r)
    
    response_lines: [dynamic]string
    for {
        msg, err := bufio.reader_read_string(&r, '\n', context.allocator)
        if err != nil {
            log.errorf("Failed to read from pipe: ", err)
            break
        }
        msg_trimmed := msg[:len(msg) -1]
        
        append(&response_lines, msg_trimmed)
        if msg_trimmed == expected {
            break
        }
    }
    return strings.join(response_lines[:], "\n", context.allocator)
}