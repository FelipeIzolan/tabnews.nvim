local request = require("tabnews.request")
local parser = require("tabnews.parser")
local map = require("tabnews.map")

local popup = require("nui.popup")
local menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

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

local unmount = function ()
  vim.g.__tabnews_open = false
  vim.api.nvim_buf_set_lines(news.bufnr, 0, 1, false, {})
  news:hide()
end

news:map("n", "<Esc>", unmount)
news:on(event.BufLeave, unmount)
news:on(event.QuitPre, unmount)

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
      return menu.item(index..". "..value.title, { path = "/"..value.owner_username.."/"..value.slug })
    end
  ),
  keymap = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
  },
  on_submit = function(item)
    local c = request("https://www.tabnews.com.br/api/v1/contents"..item.path)
    local hr = string.rep("-", news._.size.width)
    local lines = { " "..c.tabcoins .. " | " .. c.owner_username .. " | " .. c.title, hr, "", parser(c.body) }

    vim.api.nvim_buf_set_lines(news.bufnr, 0, 1, false, lines)
    news:show()

    vim.g.__tabnews_open = true
  end
})

tabnews:on(event.BufLeave, function () tabnews:unmount() end)

vim.api.nvim_create_user_command(
  "TabNews",
  function ()
    if not news._.mounted then
      news:mount()
      news:hide()
    end

    if not vim.g.__tabnews_open then
      tabnews:mount()
    end
  end,
  {}
)
