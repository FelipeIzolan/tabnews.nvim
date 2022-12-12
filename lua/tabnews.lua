local request = require("tabnews.request")
local parser = require("tabnews.parser")
local map = require("tabnews.utils.map")

local popup = require("nui.popup")
local menu = require("nui.menu")
local event = require("nui.utils.autocmd").event
local line = require("nui.line")

local tab = request("https://www.tabnews.com.br/api/v1/contents")

local news = popup({
  enter = true,
  focusable = true,
  border = {
    style = "rounded",
    text = {
      top = "  TabNews ",
      top_align = "center"
    }
  },
  position = "50%",
  size = {
    width = "90%",
    height = "90%",
  },
  win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
  buf_options = { modifiable = true }
})

local tabnews = menu(
{
  position = "50%",
  size = {
    width = "90%",
    height = "90%"
  },
  border = {
    style = "rounded",
    text = {
      top = "  TabNews ",
      top_align = "center"
    }
  },
  win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" }
},
{
  lines = map(tab,
    function (value, index)
      local n = index < 10 and "0"..index or tostring(index)
      local i = line()

      i:append(n, "__tabnews_tabcoin")
      i:append(" | ")
      i:append(value.title)

      return menu.item(i, { path = "/"..value.owner_username.."/"..value.slug })
    end
  ),
  keymap = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
  },
  on_submit = function(item)
    news:mount()
    news:map("n", "<Esc>", function () news:unmount() end)
    news:on(event.BufLeave, function () news:unmount() end)

    local c = request("https://www.tabnews.com.br/api/v1/contents"..item.path)
    local hr_width = #c.title > news._.size.width and #c.title or news._.size.width
    local hr = string.rep("-", hr_width)

    print(hr_width)

    local header = line()

    header:append(" "..c.tabcoins, "__tabnews_tabcoin")
    header:append(" | ")
    header:append(c.owner_username, "__tabnews_username")
    header:append(" | ")
    header:append(c.title)

    header:render(news.bufnr, -1, 1)
    vim.api.nvim_buf_set_lines(news.bufnr, 1, 2, false, { hr, "" })
    vim.api.nvim_buf_set_lines(news.bufnr, 2, 3, false, { parser(c.body) })
  end
})

vim.api.nvim_set_hl(0, "__tabnews_username", { bg = "#73a2ff", fg = "#013aa3" })
vim.api.nvim_set_hl(0, "__tabnews_tabcoin", { fg = "#73a2ff" })

vim.api.nvim_create_user_command(
  "TabNews",
  function ()
    if not news._.mounted then
      tabnews:mount()
      tabnews:on(event.BufLeave, function () tabnews:unmount() end)
    end
  end,
  {}
)
