package gui_sdl

import SDL "vendor:sdl2"
import "core:c"


GuiSDL :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
}

new_gui :: proc() -> GuiSDL {
    return GuiSDL{}
}

init_sdl :: proc(self: ^GuiSDL) -> (ok: bool) {

    if sdl_res := SDL.Init(SDL.INIT_VIDEO); sdl_res < 0 {
        return false
    }
    
    self.window = SDL.CreateWindow(
        "UCIFrost",
        SDL.WINDOWPOS_CENTERED,
        SDL.WINDOWPOS_CENTERED,
        800,
        800,
        SDL.WINDOW_SHOWN
    )

    if self.window == nil {
        SDL.Log("Failed to create window: %s", SDL.GetError())
        return false
    }
    
    self.renderer = SDL.CreateRenderer(self.window, -1, {.ACCELERATED, .PRESENTVSYNC})
    return self.renderer != nil
}

handle_events :: proc(self: ^GuiSDL) -> bool {
    event: SDL.Event
    for SDL.PollEvent(&event) {
        #partial switch event.type {
            case .QUIT:
                return false
        }
    }
    return true
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
                x = c.int(x * square_size),
                y = c.int(y * square_size),
                w = c.int(square_size),
                h = c.int(square_size),
            }
            SDL.RenderFillRect(self.renderer, &rect)
        }
    }
    SDL.RenderPresent(self.renderer)
}

shutdown :: proc(self: ^GuiSDL) {
    SDL.DestroyRenderer(self.renderer)
    SDL.DestroyWindow(self.window)
    SDL.Quit()
}