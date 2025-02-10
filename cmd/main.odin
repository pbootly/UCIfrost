package main

import "../internal/adapters/gui_sdl"

main :: proc() {
    gui := gui_sdl.GuiSDL{}
    if !gui.init() {
        return
    }
    defer gui.shutdown()

    running := true
    for running {
        running = gui.handle_events()
        gui.draw_board()
    }
}