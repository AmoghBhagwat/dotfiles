-- Pull in the wezterm API
local wezterm = require 'wezterm'
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.default_domain = "WSL:Ubuntu"

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font("CaskaydiaMono Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"})
config.font_size = 14.0
-- config.window_background_opacity = 0.9

config.window_padding = {
  left = 10,
  right = 10,
  top = 0,
  bottom = 0,
}

-- config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
-- config.window_decorations = "RESIZE"

-- tmux settings
config.leader = { key = "a", mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    mods = "LEADER",
    key = "c",
    action = wezterm.action.SpawnTab "CurrentPaneDomain",
  },
  {
    mods = "LEADER",
    key = "x",
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    mods = "LEADER",
    key = "b",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    mods = "LEADER",
    key = "n",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    mods = "LEADER",
    key = "w",
    action = wezterm.action.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" },
  },
  {
    mods = "LEADER",
    key = "\\",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    mods = "LEADER",
    key = "-",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain"},
  },
  {
    mods = "LEADER",
    key = "LeftArrow",
    action = wezterm.action.ActivatePaneDirection "Left",
  },
  {
    mods = "LEADER",
    key = "RightArrow",
    action = wezterm.action.ActivatePaneDirection "Right",
  },
  {
    mods = "LEADER",
    key = "DownArrow",
    action = wezterm.action.ActivatePaneDirection "Down",
  },
  {
    mods = "LEADER",
    key = "UpArrow",
    action = wezterm.action.ActivatePaneDirection "Up",
  },
  {
    mods = "CTRL|SHIFT",
    key = "LeftArrow",
    action = wezterm.action.AdjustPaneSize { "Left", 2 },
  },
  {
    mods = "CTRL|SHIFT",
    key = "RightArrow",
    action = wezterm.action.AdjustPaneSize { "Right", 2 },
  },
  {
    mods = "CTRL|SHIFT",
    key = "DownArrow",
    action = wezterm.action.AdjustPaneSize { "Down", 2 },
  },
  {
    mods = "CTRL|SHIFT",
    key = "UpArrow",
    action = wezterm.action.AdjustPaneSize { "Up", 2 },
  },
  {
    mods = "LEADER",
    key = ",",
    action = wezterm.action.PromptInputLine {
      description = "Enter name of tab",
      action = wezterm.action_callback(
        function(window, pane, line)
          window:active_tab():set_title(line)
        end
      ),
    },
  },
  {
    mods = "LEADER|SHIFT",
    key = "s",
    action = wezterm.action_callback(
      function(win, pane)
        local state = resurrect.workspace_state.get_workspace_state()
        resurrect.save_state(state)
        resurrect.window_state.save_window_action()
      end
    ),
  },
  {
    mods = "LEADER|SHIFT",
    key = "l",
    action = wezterm.action_callback(
      function(win, pane)
        resurrect.fuzzy_load(win, pane, function(id, label)
          local type = string.match(id, "^([^/]+)")
          id = string.match(id, "([^/]+)$")
          id = string.match(id, "(.+)%..+$")

          local opts = {
            window = win:mux_window(),
            relative = true,
            restore_text = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          }

          if type == "workspace" then
            local state = resurrect.load_state(id, "workspace")
            resurrect.workspace_state.restore_workspace(state, opts)
          elseif type == "window" then
            local state = resurrect.load_state(id, "window")
            resurrect.window_state.restore_window(pane:window(), state, opts)
          elseif type == "tab" then
            local state = resurrect.load_state(id, "tab")
            resurrect.tab_state.restore_tab(pane:tab(), state, opts)
          end
        end)
      end
    ),
  },
  {
    mods = "LEADER|SHIFT",
    key = "d",
    action = wezterm.action_callback(
      function(win, pane)
        resurrect.fuzzy_load(
          win,
          pane,
          function(id)
            resurrect.delete_state(id)
          end,
          {
            title             = 'Delete State',
            description       = 'Select session to delete and press Enter = accept, Esc = cancel, / = filter',
            fuzzy_description = 'Search session to delete: ',
            is_fuzzy          = true,
          }
        )
      end
    ),
  },
}

for i = 0, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i-1)
  })
end

-- show if leader key is active
wezterm.on("update-right-status", function(window, _)
  local SOLID_LEFT_ARROW = ""
  local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
  local prefix = ""

  if window:leader_is_active() then
    prefix = " " .. utf8.char(0x1f30a) -- ocean wave
    SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  end

  if window:active_tab():tab_id() ~= 0 then
    ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
  end -- arrow color based on if tab is first pane

  window:set_left_status(wezterm.format {
    { Background = { Color = "#b7bdf8" } },
    { Text = prefix },
    ARROW_FOREGROUND,
    { Text = SOLID_LEFT_ARROW }
  })
end
)

-- loads the state whenever I create a new workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
  local workspace_state = resurrect.workspace_state
  
  workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
    window = window,
    relative = true,
    restore_text = true,
    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
  })
end)

-- Saves the state whenever I select a workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
  local workspace_state = resurrect.workspace_state
  resurrect.save_state(workspace_state.get_workspace_state())
end)


resurrect.periodic_save({ interval_seconds = 5 * 60, save_workspaces = false, save_windows = true, save_tabs = false })

wezterm.on("gui-startup", resurrect.resurrect_on_gui_startup)
-- and finally, return the configuration to wezterm
return config
