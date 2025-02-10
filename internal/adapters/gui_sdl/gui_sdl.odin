package gui_sdl

import SDL "vendor:sdl2"
import "../../ports/gui"

GuiSDL :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    
    init: proc(^GuiSDL) -> bool,
    draw_board: proc(^GuiSDL),
    handle_events: proc(^GuiSDL) -> bool,
    shutdown: proc(^GuiSDL),
}

new_gui_sdl :: proc() -> gui.Gui {
    gui_sdl := GuiSDL{
        init = init,
        draw_board = draw_board,
        handle_events = handle_events,
        shutdown = shutdown,
    }
    return gui.Gui(gui_sdl) 
}


init :: proc(self: ^GuiSDL) -> bool {
    self.window = SDL.CreateWindow("UCIFrost",
        SDL.WINDOWPOS_CENTERED, SDL.WINDOWPOS_CENTERED,
        800, 800, SDL.WINDOW_SHOWN)
    
    if self.window == nil {
        SDL.Log("Failed to create window: %s", SDL.GetError())
        return false
    }
    
    self.renderer = SDL.CreateRenderer(self.window, -1, 0)
    return self.renderer != nil
}

draw_board :: proc(self: ^GuiSDL) {
    board_size := 800
    square_size := board_size / 8
    for y := 0; y < 8; y += 1 {
        for x := 0; x < 8; x += 1 {
            if (x + y) % 2 == 0 {
                SDL.SetRenderDrawColor(self.renderer, 240, 217, 181, 255)
            } else {
                SDL.SetRenderDrawColor(self.renderer, 181, 136, 99, 255)
            }

            rect := SDL.Rect{
                x = x * square_size,
                y = y * square_size,
                w = square_size,
                h = square_size
            }
            SDL.RenderFillRect(self.renderer, &rect)

        }
    }
    SDL.RenderPresent(self.renderer)
}

handle_events :: proc(self: ^GuiSDL) -> bool {
    event: SDL.Event
    for SDL.PollEvent(&event) != 0 {
        #partial switch event.type {
            case .QUIT:
                return false
        }
    }
    return true
}

shutdown :: proc(self: ^GuiSDL) {
    SDL.DestroyRenderer(self.renderer)
    SDL.DestroyWindow(self.renderer)
    SDL.Quit()
}

/*main :: proc() {
    /*if sdl2.Init(sdl.INIT_VIDEO) < 0 {
        sdl2.Load("Could not init SDL2: %s", sdl2.GetError())
        return
    }
    defer sdl2.Quit()*/

    window := sdl2.CreateWindow("UCIFrost",
        sdl2.WINDOWPOS_CENTERED, sdl2.WINDOWPOS_CENTERED,
        800, 800, sdl2.WINDOW_SHOWN
    )

    if window == nil {
        sdl2.Log("Failed to create window: %s", sdl2.GetError())
        return
    }
    defer sdl2.DestroyWindow(window)

    renderer := sdl2.CreateRenderer(window, -1, nil)
    if renderer == nil {
        sdl2.Log("Failed to create renderer: %s", sdl2.GetError())
        return
    }
    defer sdl2.DestroyRenderer(renderer)

    running := true
    event: sdl2.Event
    for running {
        for sdl2.PollEvent(&event) {
            #partial switch event.type {
            case .QUIT:
                running = false
            }
        }
        sdl2.SetRenderDrawColor(renderer, 255,255,255,255)
        sdl2.RenderClear(renderer)
        sdl2.RenderPresent(renderer)
    }

    
}*/