---@type table<integer, TSNode>
local stack = {}

local function register_cleanup()
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "[vV\x16]*:*",
    callback = function()
      stack = {}
    end,
    once = true,
  })
end

---@param node TSNode
local function push_node(node)
  table.insert(stack, node)
end

local function pop_node()
  table.remove(stack)
end

---@return TSNode?
local function get_node()
  return stack[#stack]
end

---@param node TSNode
local function update_selection(node)
  local start_row, start_col, end_row, end_col = node:range()
  start_row = start_row + 1
  start_col = start_col + 1
  end_row = end_row + 1

  if end_col == 0 then
    end_row = end_row - 1
    end_col = #vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, false)[1]
    end_col = math.max(end_col, 1)
  end

  vim.api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
  vim.cmd "normal! o"
  vim.api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

---@param p TSNode?
---@param q TSNode?
---@return TSNode?
local function common_ancestor(p, q)
  if not p or not q then return end
  if p == q then return p end
  if vim.treesitter.is_ancestor(p, q) then return p end
  if vim.treesitter.is_ancestor(q, p) then return q end
  return common_ancestor(p:parent(), q:parent())
end

---@return [integer, integer]
local function get_pos()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  return { row - 1, col }
end

---@return boolean
local function init_visual_selection()
  local p = vim.treesitter.get_node { pos = get_pos() }
  vim.cmd "normal! o"
  local q = vim.treesitter.get_node { pos = get_pos() }
  vim.cmd "normal! o"

  local node = common_ancestor(p, q)
  if not node then return false end
  register_cleanup()
  push_node(node)
  update_selection(node)
  return true
end

--- return true if nodes selected
---@return boolean
local function init_selection()
  local node = vim.treesitter.get_node()
  if not node then return false end
  register_cleanup()
  push_node(node)
  vim.cmd "normal! v"
  update_selection(node)
  return true
end

---@param node TSNode
---@return TSNode?
local function larger_parent(node)
  local parent = node:parent()
  if not parent then return end
  if parent:byte_length() == node:byte_length() then
    return larger_parent(parent)
  end
  return parent
end

local function incremental()
  local node = get_node()
  if not node then return init_visual_selection() end
  local node = larger_parent(node)
  if node then
    push_node(node)
    update_selection(node)
  end
  return true
end

local function decremental()
  if #stack == 0 then return false end
  if #stack == 1 then return true end
  pop_node()
  local node = get_node()
  if node then
    update_selection(node)
  end
  return true
end

return {
  init_selection = init_selection,
  incremental = incremental,
  decremental = decremental,
}
