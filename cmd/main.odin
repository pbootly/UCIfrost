package main

import "core:log"
import "../src/gui_sdl"

main :: proc() {
    context.logger = log.create_console_logger()

    gui := gui_sdl.new_gui()
    if res := gui_sdl.init_sdl(&gui); !res {
        log.errorf("Initialization failed")
    }
    defer gui_sdl.shutdown(&gui)

    running := true
    for running {
        running = gui_sdl.handle_events(&gui)
        gui_sdl.draw_board(&gui)
    }
}