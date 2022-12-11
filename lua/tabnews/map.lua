function Map(t, callback)
  local result = {}

  assert(type(t) == "table", "t must be a table.")

  -- Array's
  if t[1] ~= nil then
    for index, value in ipairs(t) do
      table.insert(result, callback(value, index))
    end
  -- Dictionary's
  else
    for key, value in pairs(t) do
      result[key] = callback(value, key)
    end
  end

  return result
end

return Map
