package main

import "core:log"
import os "core:os/os2"
import "../src/gui_sdl"
import "../src/uci"
import "../src/process"

main :: proc() {
    context.logger = log.create_console_logger()

    gui := gui_sdl.new_gui()
    if res := gui_sdl.init_sdl(&gui); !res {
        log.errorf("SDL initialization failed")
    }
    defer gui_sdl.shutdown(&gui)
    e := process.new_process()
    e.name = "stockfish"
    if res, err := process.init_process(&e); !res || err != nil {
        log.errorf("Engine process initalization failed")
    }
    defer process.shutdown(&e)
    if !uci.init(&e.pipes) {
        log.error("Failed to initialize UCI")
        return
    }

    running := true
    board := gui_sdl.Board {}
    board.size = 800
    for running {
        running = gui_sdl.handle_events(&gui)
        gui_sdl.draw_board(&gui, &board)
        
        if gui_sdl.has_user_move(&gui) {
            user_move := gui_sdl.get_user_move(&gui)
            uci.message_engine(uci.create_command(uci.UCI.POSITION, user_move), &e.pipes)
            uci.message_engine(uci.create_command(uci.UCI.GO, "depth 10"), &e.pipes)
            best_move := uci.read_from_engine(&e.pipes, "bestmove")
        }
    }
    _,_=os.process_wait(e.process)
}