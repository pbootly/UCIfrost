package uci

import os "core:os/os2"
import "core:log"
import "core:bufio"
import "../engine"
import "core:time"

init :: proc(self: ^engine.ProcessPipes) {
    log.debug("sleeping")
    time.sleep(10 * time.Second)
    log.debug("slept")
    message_engine("uci\n", self)
    for i:=0; i < 100; i+=1 {
        uci := read_from_engine(self)
        log.debug(uci)
        if uci == "uciok" {
            log.debug("FOUND IT", uci)
            break
        }
    }

}

message_engine :: proc(msg: string, self: ^engine.ProcessPipes) {
    message := transmute([]u8)msg
    log.debug("Messaging engine:", msg)
    _, err := os.write(self.stdin_write, message)
    if err != nil {
        log.errorf("Process write error: ", err)
    }
}

read_from_engine :: proc(self: ^engine.ProcessPipes) -> string {
    r: bufio.Reader
    buffer: [1024]byte
    bufio.reader_init_with_buf(&r, self.stdout_read.stream, buffer[:])
    defer bufio.reader_destroy(&r)

    msg, err := bufio.reader_read_string(&r, '\n', context.allocator)
    if err != nil {
        log.errorf("Failed to read from pipe", err)
    }
    log.debug("Received:", msg)
    return msg
}