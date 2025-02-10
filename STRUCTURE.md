
Notes for future self - this has the potential to baloon so went with a simple-ish ports and adapters interface, that way when I hit a wall I can pivot out just parts of it.

Rough thinking:
`cmd/`
- Entry point of application
- Writes up dependencies (GUI, UCI Engine, ETC)

`internal/app/`
- `game.odin` keeps track of game state
- `engine.odin` handles UCI protocol and external engine process runtime

`internal/board/` represents chessboard state
`internal/move/` handles chess move validation

`internal/adapters`
Implements interfaces from `ports/` to connect GUI and UCI
- `gui_sdl` sdl2 renderer for the board
- `uci_engine` uci process manager

`internal/ports`
Defines abstractions for GUI and UCI
- `gui` interface for graphical interactions
- `uci` interface for communicating with UCI engines

`pkg`
Reusable components