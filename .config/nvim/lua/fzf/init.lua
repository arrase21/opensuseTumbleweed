local function fzf_ui(cmd, on_select)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })

  local width = math.ceil(vim.o.columns * 0.8)
  local height = math.ceil(vim.o.lines * 0.4)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.ceil((vim.o.columns - width) / 2),
    row = math.ceil((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded'
  })

  local win_opts = { scope = 'local', win = win }
  vim.api.nvim_set_option_value('number', false, win_opts)
  vim.api.nvim_set_option_value('relativenumber', false, win_opts)
  vim.api.nvim_set_option_value('signcolumn', 'no', win_opts)

  local root_result = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")
  local root = (vim.v.shell_error == 0 and root_result[1] and not root_result[1]:match("^fatal"))
      and root_result[1]
      or vim.fn.getcwd()

  local temp = vim.fn.tempname()
  local full_cmd = string.format("cd %s && %s > %s", vim.fn.shellescape(root), cmd, vim.fn.shellescape(temp))

  vim.fn.termopen({ "sh", "-c", full_cmd }, {
    on_exit = function(_, code)
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      local function cleanup()
        if vim.fn.filereadable(temp) == 1 then os.remove(temp) end
      end

      if code == 0 and vim.fn.filereadable(temp) == 1 then
        local f = io.open(temp, "r")
        if not f then
          cleanup()
          return
        end
        local content = f:read("*all")
        f:close()
        cleanup()

        local selection = content:gsub("\n$", "")
        if selection ~= "" then
          vim.schedule(function() on_select(selection, root) end)
        end
      else
        cleanup()
      end
    end
  })

  vim.cmd("startinsert")
end
local fzf_base = "fzf --border=none --margin=0,0 --padding=0,0 --no-height --layout=reverse --no-popup "
local bat_preview = "bat --color=always --style=numbers"

local function git_checkout(target, notify_msg)
  local output = vim.fn.system("git checkout " .. vim.fn.shellescape(target))
  if vim.v.shell_error == 0 then
    vim.cmd("checktime")
    vim.notify(notify_msg, vim.log.levels.INFO)
  else
    vim.notify("❌ Error: " .. output, vim.log.levels.ERROR)
  end
end

vim.keymap.set('n', '<leader>z', function()
  local cmd = fzf_base ..
      string.format("--preview '%s --line-range :500 {}' --preview-window=right:60%%", bat_preview)
  fzf_ui(cmd, function(selection, root)
    vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. selection))
  end)
end, { desc = 'FZF: Archivos' })

vim.keymap.set('n', '<leader>rg', function()
  local rg = "rg --column --line-number --no-heading --color=always --smart-case ''"
  local preview = string.format("--preview '%s --highlight-line {2} {1}' --preview-window=right:60%%", bat_preview)
  local fzf_cmd = fzf_base .. "--ansi --delimiter ':' " .. preview
  local cmd = rg .. " | " .. fzf_cmd
  fzf_ui(cmd, function(selection, root)
    local filepath, lnum, col = selection:match("^([^:]+):(%d+):(%d+):")
    if filepath and lnum and col then
      vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. filepath))
      vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
    end
  end)
end, { desc = 'FZF: Texto' })

vim.keymap.set('n', '<leader>rb', function()
  local cmd = "git branch -a --color=always | grep -v '/HEAD' | sed 's/^[* ]*//'"
  local fzf_cmd = fzf_base .. "--ansi --preview 'git log --color=always {}'"
  fzf_ui(cmd .. " | " .. fzf_cmd, function(selection)
    local branch = selection:gsub("^remotes/[^/]+/", "")
    git_checkout(branch, "✅ Branch: " .. branch)
  end)
end, { desc = 'FZF Git: Branches' })

vim.keymap.set('n', '<leader>rl', function()
  local cmd = "git log --oneline --color=always"
  local fzf_cmd = fzf_base ..
      "--ansi " ..
      "--preview 'git show --color=always {1}' " ..
      "--header 'Enter para hacer CHECKOUT a este commit (detached HEAD)'"

  fzf_ui(cmd .. " | " .. fzf_cmd, function(selection)
    local hash = selection:match("^(%S+)")
    if hash then
      git_checkout(
        hash,
        "🚀 Commit: " .. hash .. "\n⚠️  Estás en modo detached HEAD.\nCrea un branch con: git switch -c <nombre>"
      )
    end
  end)
end, { desc = 'FZF Git: Checkout a Commit' })

vim.keymap.set('n', '<leader>rs', function()
  local cmd = "git status --short"
  local fzf_cmd = fzf_base .. "--preview 'git diff --color=always {2}'"

  fzf_ui(cmd .. " | " .. fzf_cmd, function(selection, root)
    local file = selection:match("^..(.*)")
    if file then
      file = file:match("^%s*(.-)%s*$") -- trim
      local renamed = file:match("^.+ %-> (.+)$")
      file = renamed or file
      vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. file))
    else
      vim.notify("❌ No se pudo parsear el archivo: " .. selection, vim.log.levels.ERROR)
    end
  end)
end, { desc = 'FZF Git: Status' })

