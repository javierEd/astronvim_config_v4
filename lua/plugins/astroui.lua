-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local colorscheme_day_night = function(day, night)
  local current_hour = tonumber(os.date("%H", os.time()))

  if current_hour >= 18 or current_hour < 6 then return night end

  return day
end

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = colorscheme_day_night("astrodark", "astromars"),
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
      },
      astrotheme = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    -- icons = {
    --   -- configure the loading of the lsp in the status line
    --   LSPLoading1 = "⠋",
    --   LSPLoading2 = "⠙",
    --   LSPLoading3 = "⠹",
    --   LSPLoading4 = "⠸",
    --   LSPLoading5 = "⠼",
    --   LSPLoading6 = "⠴",
    --   LSPLoading7 = "⠦",
    --   LSPLoading8 = "⠧",
    --   LSPLoading9 = "⠇",
    --   LSPLoading10 = "⠏",
    -- },
  },
}
