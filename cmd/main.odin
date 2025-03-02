package main

import "core:log"
import os "core:os/os2"
import "../src/gui_sdl"
import "../src/engine"
import "../src/uci"

main :: proc() {
    context.logger = log.create_console_logger()

    gui := gui_sdl.new_gui()
    if res := gui_sdl.init_sdl(&gui); !res {
        log.errorf("SDL initialization failed")
    }
    defer gui_sdl.shutdown(&gui)
    e := engine.new_process()
    e.name = "stockfish"
    if res, err := engine.init_process(&e); !res || err != nil {
        log.errorf("Engine process initalization failed")
    }
    defer engine.shutdown(&e)
    uci.init(&e.pipes)

    running := true
    board := gui_sdl.Board {}
    board.size = 800
    for running {
        running = gui_sdl.handle_events(&gui)
        gui_sdl.draw_board(&gui, &board)
    }
    _,_=os.process_wait(e.process)
}