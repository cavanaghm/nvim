local dap = require("dap")
require("mason-nvim-dap").setup({
	ensure_installed = { "delve" },
	automatic_installation = true,
})
local dapui = require("dapui")
dapui.setup()

dap.adapters.delve = function(callback, config)
	if config.mode == "remote" and config.request == "attach" then
		callback({
			type = "server",
			host = config.host or "127.0.0.1",
			port = config.port or "38697",
		})
	else
		callback({
			type = "server",
			port = "${port}",
			executable = {
				command = "dlv",
				args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
				detached = vim.fn.has("win32") == 0,
			},
		})
	end
end

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
	{
		type = "delve",
		name = "Debug package tests",
		request = "launch",
		mode = "test",
		args = { "-test.v" },
		program = "${fileDirname}",
	},
	-- {
	-- 	type = "delve",
	-- 	name = "Debug current test file",
	-- 	request = "launch",
	-- 	mode = "test",
	-- 	program = "${file}",
	-- },
	-- {
	-- 	type = "delve",
	-- 	name = "Attach to Modd (Port 2345)",
	-- 	request = "attach",
	-- 	mode = "remote",
	-- 	port = 2345,
	-- 	host = "127.0.0.1",
	-- },
}

vim.keymap.set("n", "<leader>uu", dapui.toggle)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>gb", dap.run_to_cursor)
vim.keymap.set("n", "<leader>?", function()
	dapui.eval(nil, { enter = true })
end)
vim.keymap.set("n", "<leader>dB", dap.clear_breakpoints)
vim.keymap.set("n", "<leader>dr", dap.repl.open)

vim.keymap.set("n", "<leader>dc", dap.continue)

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end
