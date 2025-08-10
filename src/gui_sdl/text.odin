package gui_sdl

import "../utils"
import "core:c"
import "core:log"
import SDL "vendor:sdl2"
import "vendor:sdl2/ttf"


init_font :: proc(path: string, size: int) -> ^ttf.Font {
	if ttf.Init() != 0 {
		log.error("Failed to init SDL_ttf: %s", ttf.GetError())
	}

	cpath := utils.string_to_cstring(path)
	font := ttf.OpenFont(cpath, c.int(size))
	if font == nil {
		log.error("Failed to load font: %s", ttf.GetError())
	}

	return font
}
render_text :: proc(self: ^GuiSDL, text: string, x: int, y: int, color: SDL.Color) {
	c_text := utils.string_to_cstring(text)
	surface := ttf.RenderUTF8_Solid(self.font, c_text, color)
	if surface == nil {
		SDL.Log("Failed to render text surface: %s", ttf.GetError())
		return
	}
	defer SDL.FreeSurface(surface)

	texture := SDL.CreateTextureFromSurface(self.renderer, surface)
	if texture == nil {
		SDL.Log("Failed to create texture from surface: %s", SDL.GetError())
		return
	}
	defer SDL.DestroyTexture(texture)

	dst := SDL.Rect {
		x = c.int(x),
		y = c.int(y),
		w = surface.w,
		h = surface.h,
	}
	SDL.RenderCopy(self.renderer, texture, nil, &dst)
}
