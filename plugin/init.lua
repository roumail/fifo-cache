-- fifo_gate.lua
local M = {}

function M.new(capacity)
  local seen = {}
  local order = {}
  local ready = false

  local function evict_key(v)
    if v == nil then return nil end
    for i, val in ipairs(order) do
      if val == v then
        table.remove(order, i)
        seen[v] = nil
        break
      end
    end
    ready = (#order >= capacity)
  end

  local function filter_order(predicate)
    local new_order = {}
    for _, v in ipairs(order) do
      if predicate(v) then
        table.insert(new_order, v)
      else
        seen[v] = nil
      end
    end
    order = new_order
  end

  local function evict_keys(keys)
    if not keys then return end
    local to_remove = {}
    for _, k in ipairs(keys) do
      to_remove[k] = true
    end

    filter_order(function(v)
      return not to_remove[v]
    end)
    ready = (#order >= capacity)
  end

  local function evict_oldest()
    local oldest = table.remove(order, 1)
    if oldest then
      seen[oldest] = nil
    end
  end

  local function add_value(v)
    if v == nil then return nil end
    if not seen[v] then
      if #order >= capacity then
        evict_oldest()
      end

      seen[v] = true
      table.insert(order, v)
    end

    if #order >= capacity then
      ready = true
    end

    return ready
  end

  local function is_ready()
    return ready
  end

  local function get_cache()
    local copy = {}
    for i, v in ipairs(order) do
      copy[i] = v
    end
    return copy
  end

    local function reverse()
        local len = #order
        for i = 1, math.floor(len / 2) do
            order[i], order[len - i + 1] = order[len - i + 1], order[i]
        end
    end
    return {
        add_value = add_value,
        is_ready = is_ready,
        get_cache = get_cache,
        reverse = reverse
    }
end

return M
