inventory_update_game:
    rcall inventory_render_game
    rcall inventory_handle_controls
    ret

inventory_handle_controls:
    ret

inventory_render_game:
    rcall render_game
    ret
