-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Mirror the macOS line-edit shortcuts that iTerm2's GlobalKeyMap forwards:
--   Option+Left/Right -> \eb / \ef   (received here as <M-b> / <M-f>)
--   Cmd+Left/Right    -> ^A  / ^E    (received here as <C-a>  / <C-e>)
--   Cmd+Backspace     -> ^U          (kill to start of line)
--   Option+Backspace  -> \e^?        (kill previous word)
local map = vim.keymap.set

-- Insert mode: word + line motion, plus the two kill bindings
map("i", "<M-b>", "<C-Left>",  { desc = "Word backward" })
map("i", "<M-f>", "<C-Right>", { desc = "Word forward" })
map("i", "<C-a>", "<Home>",    { desc = "Start of line" })
map("i", "<C-e>", "<End>",     { desc = "End of line" })
map("i", "<C-u>", "<C-o>d0",   { desc = "Kill to start of line" })

-- Command-line mode: same motion. <C-e> is already end-of-cmdline by default.
map("c", "<M-b>", "<C-Left>",  { desc = "Word backward" })
map("c", "<M-f>", "<C-Right>", { desc = "Word forward" })
map("c", "<C-a>", "<Home>",    { desc = "Start of cmdline" })
