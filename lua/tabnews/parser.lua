function Parser(body)
  local result = {}
  local text = body
  local text_max_width = 72
  local s, e = text:find("\n")

  -- table
  while s do
    s, e = text:find("\n")
    if not s then break end
    table.insert(result, text:sub(0, s - 1))
    table.insert(result, "")
    text = text:sub(e + 1)
  end

  table.insert(result, text)

  -- width
  for i, value in ipairs(result) do
    local pos = value:find(" ", text_max_width)

    if #value > text_max_width then
      local x = pos and pos or #value
      result[i] = value:sub(0, x)
      table.insert(result, i + 1, value:sub(x + 1))
    end

  end

  return table.unpack(result)
end

return Parser
