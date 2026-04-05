local wezterm = require 'wezterm'

local config = wezterm.config_builder()
config.color_scheme = 'Catppuccin Mocha'
config.colors = config.colors or {}
config.colors.selection_fg = "#1e1e2e"  -- text color when selected
config.colors.selection_bg = "#b4befe"  -- visible highlight
config.font = wezterm.font('MonaspiceNe Nerd Font')
config.window_decorations = 'NONE'
-- config.window_close_confirmation = 'NeverPrompt'
config.enable_tab_bar = false
config.wsl_domains = {
  {
    name = 'arch',
    distribution = 'arch',
    default_cwd = "~"
  },
}
-- config.default_domain = 'arch'

return config
