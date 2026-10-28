local function load_env(file_path)
  local f = io.open(file_path, "r")
  if not f then
    return
  end

  for line in f:lines() do
    -- ignore comments and empty lines
    if not line:match("^%s*#") and line:match("=") then
      local key, value = line:match("^%s*([^=]+)%s*=%s*(.*)%s*$")
      if key and value then
        -- remove surrounding quotes if they exist
        value = value:gsub("^['\"]", ""):gsub("['\"]$", "")
        -- set environment variable for Neovim and child processes
        vim.fn.setenv(key, value)
      end
    end
  end

  f:close()
end

load_env(vim.fn.stdpath("config") .. "/.env")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
