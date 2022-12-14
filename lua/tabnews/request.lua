local decode = require("tabnews.utils.decode")

local function request (url)
  local req = assert(io.popen("curl "..url, "r"))
  local data = decode(req:read("a"))

  req:close()
  vim.cmd(":mode") -- clear io.popen log's 

  return data
end

return request
