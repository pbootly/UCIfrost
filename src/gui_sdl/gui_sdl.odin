package gui_sdl

import "core:c"
import "core:fmt"
import "core:log"
import "core:strings"
import SDL "vendor:sdl2"

GuiSDL :: struct {
	window:   ^SDL.Window,
	renderer: ^SDL.Renderer,
}

Board :: struct {
	size: int,
}

Bitboard :: struct {
	white_pieces:  u64,
	black_pieces:  u64,
	white_pawns:   u64,
	black_pawns:   u64,
	white_rooks:   u64,
	black_rooks:   u64,
	white_knights: u64,
	black_knights: u64,
	white_bishops: u64,
	black_bishops: u64,
	white_queen:   u64,
	black_queen:   u64,
	white_king:    u64,
	black_king:    u64,
}

Square :: struct {
	rank: i32,
	file: i32,
}

new_gui :: proc() -> GuiSDL {
	return GuiSDL{}
}

init_sdl :: proc(self: ^GuiSDL) -> (ok: bool) {

	if sdl_res := SDL.Init(SDL.INIT_VIDEO); sdl_res < 0 {
		SDL.Log("Failed to init SDL: %s", SDL.GetError())
		return false
	}

	self.window = SDL.CreateWindow(
		"UCIFrost",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		800,
		800,
		SDL.WINDOW_SHOWN,
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
			SDL.Log("Quitting UCIFrost UI")
			return false
		case .MOUSEBUTTONDOWN:
			if event.button.button == SDL.BUTTON_LEFT {
				mouse_x := event.button.x
				mouse_y := event.button.y
				square := position_to_square(self, mouse_x, mouse_y)
				noted := square_to_algebraic(square)
				SDL.Log("noted: %s", noted)
				// Highlight
			}
		}
	}
	return true
}

position_to_square :: proc(self: ^GuiSDL, mouse_x: i32, mouse_y: i32) -> Square {
	window_width, window_height: i32 = 0, 0
	SDL.GetWindowSize(self.window, &window_width, &window_height)
	square_size := window_width / 8 // Assumes width and height are always equal
	rank := mouse_y / square_size
	file := mouse_x / square_size
	return {rank, file}
}

square_to_algebraic :: proc(square: Square) -> string {
	ranks := "abcdefgh"
	file := ranks[square.file]
	rank := 8 - square.rank

	buf := make([]u8, 10)
	fmt.bprintf(buf, "%c%d", file, rank)

	return string(buf)
}

draw_board :: proc(self: ^GuiSDL, board: ^Board) {
	square_size := board.size / 8
	for y := 0; y < 8; y += 1 {
		for x := 0; x < 8; x += 1 {
			if (x + y) % 2 == 0 {
				SDL.SetRenderDrawColor(self.renderer, 240, 217, 181, 255)
			} else {
				SDL.SetRenderDrawColor(self.renderer, 181, 136, 99, 255)
			}

			rect := SDL.Rect {
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
