local M = {}
local window = require("preview.windows")
local function is_git_commit(item)
  if type(item) ~= "string" then return false end
  return item:match("^%x%x%x%x%x%x%x") ~= nil
end
local function is_git_branch(item)
  if type(item) ~= "string" then return false end
  return item:match("^[%*%s][%s]%S") ~= nil and not is_git_commit(item)
end

local function preview_git_commit(preview_buf, hash)
  local clean_hash = hash:match("^(%x+)")
  if not clean_hash then return end
  local ok, result = pcall(vim.fn.systemlist, "git show --stat --color=never " .. clean_hash)
  if not ok or vim.v.shell_error ~= 0 then return end
  vim.bo[preview_buf].modifiable = true
  vim.bo[preview_buf].filetype = "git"
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, result)
  vim.bo[preview_buf].modifiable = false
end

local function preview_git_branch(preview_buf, branch_line)
  local branch = branch_line:match("^%*?%s*(.-)%s*$")
  branch = branch:match("^%((.-)%)$") or branch
  if not branch or branch == "" then return end
  local ok, result = pcall(vim.fn.systemlist, "git log --oneline -20 --color=never " .. branch)
  if not ok or vim.v.shell_error ~= 0 then return end
  vim.bo[preview_buf].modifiable = true
  vim.bo[preview_buf].filetype = "git"
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, result)
  vim.bo[preview_buf].modifiable = false
end

local function reset_preview_buf(preview_buf)
  vim.bo[preview_buf].modifiable = true
  vim.bo[preview_buf].filetype = ""
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})
end

-- タイマー状態管理
local current_timer = nil
local last_item = nil
---プレビューを更新する（共通処理）
---@param item any 現在選択されているアイテム
local function update_preview(item)
  if not window.is_open() then return end
  if not MiniPick or not MiniPick.default_preview then return end
  local preview_buf = window.get_preview_buf()
  if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then return end
  pcall(function()
    -- Solo intentar git preview si el item es string puro
    if type(item) == "string" and is_git_commit(item) then
      preview_git_commit(preview_buf, item)
    elseif type(item) == "string" and is_git_branch(item) then
      preview_git_branch(preview_buf, item)
    else
      reset_preview_buf(preview_buf)
      MiniPick.default_preview(preview_buf, item)
    end
    vim.defer_fn(function()
      pcall(vim.cmd, "redraw")
    end, MiniPick.config.delay.async)
  end)
end
local function on_timer_tick()
  vim.schedule(function()
    local ok, err = pcall(function()
      if not MiniPick or not MiniPick.get_picker_matches then return end
      local ok_matches, matches = pcall(MiniPick.get_picker_matches)
      if not ok_matches or not matches then return end
      local item = matches.current
      if not item then return end
      if item ~= last_item then
        last_item = item
        update_preview(item)
      end
    end)
    if not ok then
      vim.notify("Error in timer callback: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end
local function on_pick_start()
  window.open()
  last_item = nil
  current_timer = vim.uv.new_timer()
  current_timer:start(100, 100, on_timer_tick)

  vim.schedule(function()
    if not MiniPick then return end
    local current_mappings = MiniPick.get_picker_opts().mappings or {}

    current_mappings.preview_down = {
      char = '<C-j>',
      func = function()
        window.scroll("down")
      end,
    }
    current_mappings.preview_up = {
      char = '<C-k>',
      func = function()
        window.scroll("up")
      end,
    }
    MiniPick.set_picker_opts({ mappings = current_mappings })
  end)
end

local function on_pick_stop()
  if current_timer then
    current_timer:stop()
    current_timer:close()
    current_timer = nil
  end
  last_item = nil
  window.close()
end
function M.setup()
  local group = vim.api.nvim_create_augroup("MiniPickPreview", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniPickStart",
    callback = on_pick_start,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniPickStop",
    callback = on_pick_stop,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if window.is_open() then
        window.respawn()
      end
    end,
  })
end

return M
