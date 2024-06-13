return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",

		"thenbe/neotest-playwright",
	},

	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-playwright").adapter({
					options = {
						persist_project_selection = true,
						enable_dynamic_test_discovery = true,
						preset = "debug",
					},
				}),
			},
		})

		vim.keymap.set("n", "<leader>tt", require("neotest").summary.toggle, { desc = "[T]est [T]oggle summary" })
	end,
}
