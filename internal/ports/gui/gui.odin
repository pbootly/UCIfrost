package gui

Gui :: struct {
    init: proc(^Gui) -> bool,
    draw_board: proc(^Gui),
    handle_events: proc(^Gui) -> bool,
    shutdown: proc(^Gui),
}