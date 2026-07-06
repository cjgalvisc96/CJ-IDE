-- Python debugging (DAP), VSCode-style. The dap.core extra (enabled in
-- config/lazy.lua) provides nvim-dap + dap-ui + inline virtual text, and the
-- lang.python extra already points nvim-dap-python at the `debugpy-adapter`
-- executable — installed on your PATH by mise (pipx:debugpy in
-- config/mise/tools.txt), so there is NOTHING to wire up here beyond keys.
--
-- Two key sets drive the debugger:
--
--   CJ-IDE Ctrl keys           VSCode function keys (exact same actions)
--   ------------------         ----------------------------------------
--   <C-p>   run / continue     <F5>        Start / Continue
--   <C-b>   toggle breakpoint  <F9>        Toggle Breakpoint
--   <C-S-b> clear breakpoints  <S-F5>      Stop / Terminate
--   <C-d>   step over          <C-S-F5>    Restart
--   <C-f>   step out           <F10>       Step Over
--   <C-S-p> terminate          <F11>       Step Into
--                              <S-F11>     Step Out
--                              <F6>        Pause
--
-- Heads up: <C-S-b>, <C-S-p> and the shifted F-keys (<S-F5>/<S-F11>) only reach
-- nvim on terminals that distinguish Shift+key (kitty/ghostty/wezterm); <C-S-p>
-- is written with an explicit Shift so it can't collapse onto <C-p> (continue).
-- If a shifted key doesn't fire, use its <leader>d… twin (press ? for the
-- cheatsheet). <C-d>/<C-f> override the default half-page scroll in normal mode
-- (CJ-IDE scrolls with <C-h>/<C-l>). "Clear all breakpoints" is also <leader>dx.
-- Merged into (not replacing) LazyVim's nvim-dap keys, lazy-loaded on press.
return {
  {
    "mfussenegger/nvim-dap",
    -- stylua: ignore
    keys = {
      -- CJ-IDE Ctrl keys
      { "<C-p>", function() require("dap").continue() end, desc = "Debug: run / continue" },
      { "<C-b>", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<C-S-b>", function() require("dap").clear_breakpoints() end, desc = "Debug: clear all breakpoints" },
      { "<C-d>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<C-f>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<C-S-p>", function() require("dap").terminate() end, desc = "Debug: terminate" },
      { "<leader>dx", function() require("dap").clear_breakpoints() end, desc = "Clear all breakpoints" },
      -- VSCode function keys
      { "<F5>", function() require("dap").continue() end, desc = "Debug: start / continue" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: stop" },
      { "<C-S-F5>", function() require("dap").restart() end, desc = "Debug: restart" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<F6>", function() require("dap").pause() end, desc = "Debug: pause" },
    },
  },
}
