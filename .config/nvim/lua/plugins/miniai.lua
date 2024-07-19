return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [']quote
		--  - ci'  - [C]hange [I]nside [']euote
		local spec_treesitter = require("mini.ai").gen_spec.treesitter
		require("mini.ai").setup({
			n_lines = 500,
			custom_textobjects = {
				F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
				c = spec_treesitter({
					a = "@class.outer",
					i = "@class.inner",
				}),
			},
		})

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		require("mini.surround").setup()
		--
		-- ... and there is more!
		--  Check out: https://github.com/echasnovski/mini.nvim
	end,
}
