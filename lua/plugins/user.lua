-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    "akinsho/pubspec-assist.nvim",
    dependencies = "plenary.nvim",
    lazy = true,
    event = { "BufRead pubspec.yaml" },
    opts = {},
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "right",
      },
    },
  },

  { "projectfluent/fluent.vim" },

  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"
      local job = require "plenary.job"

      local trim = function(value) return string.gsub(value, "^%s*(.-)%s*$", "%1") end

      local wt_today = "0 secs"
      local wt_cli_location = ""

      local wt_condition = function(self)
        if self.job ~= nil then return true end

        wt_cli_location = trim(vim.fn.execute("WakaTimeCliLocation", "silent!"))

        if wt_cli_location ~= "" then return true end

        return false
      end

      local wt_has_to_start_job = function(self) return self.current_time == nil or self.current_time + 60 <= os.time() end

      local wt_today_has_changed = function(self) return self.today ~= wt_today end

      local wt_today_init = function(self)
        if self.job == nil then
          self.job = job:new {
            command = wt_cli_location,
            args = { "--today" },
            on_exit = function(j, _)
              local today = trim(j:result()[1])

              if today == "" then return end

              wt_today = trim(j:result()[1])
            end,
          }

          self.prefix = "󰄉 WT "
          self.today = wt_today
        end

        if wt_has_to_start_job(self) then self.job:start() end

        if wt_today_has_changed(self) then self.today = wt_today end

        self.current_time = os.time()
      end

      local wt_provider = function(self) return self.prefix .. self.today end

      local wt_update = function(self) return wt_today_has_changed(self) or wt_has_to_start_job(self) end

      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode { mode_text = { padding = { left = 1, right = 1 } } },
        status.component.git_branch(),
        status.component.file_info(),
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        {
          condition = wt_condition,
          init = wt_today_init,
          provider = wt_provider,
          update = wt_update,
        },
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode { surround = { separator = "right" } },
      }

      opts.winbar = { -- create custom winbar
        -- store the current buffer number
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false, -- pick the correct winbar based on condition
        -- inactive winbar
        {
          condition = function() return not status.condition.is_active() end,
          -- show the path to the file relative to the working directory
          status.component.separated_path {
            path_func = status.provider.filename { modify = ":.:h" },
          },
          -- add the file name and icon
          status.component.file_info {
            file_icon = {
              hl = status.hl.file_icon "winbar",
              padding = { left = 0 },
            },
            filename = {},
            filetype = false,
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbarnc", true),
            surround = false,
            update = "BufEnter",
          },
        },
        -- active winbar
        {
          -- show the path to the file relative to the working directory
          status.component.separated_path {
            path_func = status.provider.filename { modify = ":.:h" },
          },
          -- add the file name and icon
          status.component.file_info { -- add file_info to breadcrumbs
            file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
            filename = {},
            filetype = false,
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbar", true),
            surround = false,
            update = "BufEnter",
          },
          -- show the breadcrumbs
          status.component.breadcrumbs {
            icon = { hl = true },
            hl = status.hl.get_attributes("winbar", true),
            prefix = true,
            padding = { left = 0 },
          },
        },
      }

      opts.tabline = { -- tabline
        { -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            self.winwidth = vim.api.nvim_win_get_width(self.winid)
            return self.winwidth ~= vim.o.columns -- only apply to sidebars
              and not require("astrocore.buffer").is_valid(vim.api.nvim_win_get_buf(self.winid)) -- if buffer is not in tabline
          end,
          provider = function(self) return (" "):rep(self.winwidth + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist { -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          { -- close button for current tab
            provider = status.provider.close_button {
              kind = "TabClose",
              padding = { left = 1, right = 1 },
            },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astrocore.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      }

      opts.statuscolumn = { -- statuscolumn
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        status.component.foldcolumn(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      }
    end,
  },
}
