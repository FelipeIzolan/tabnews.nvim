local decode = require("tabnews.decode")

function Request (url)
  local req = assert(io.popen("curl "..url, "r"))
  local data = decode(req:read("a"))

  req:close()
  vim.cmd(":mode") -- clear io.popen log's 

  return data
end

return Request
