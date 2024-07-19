return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		settings = {
			sync_on_ui_close = true,
			save_on_toggle = true,
		},
	},
	config = function(_, opts)
		local harpoon = require("harpoon")
		harpoon.setup(opts)

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end)
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		vim.keymap.set("n", "<leader>h", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<leader>j", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<leader>k", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<leader>l", function()
			harpoon:list():select(4)
		end)
		vim.keymap.set("n", "<leader>;", function()
			harpoon:list():select(5)
		end)
		vim.keymap.set("n", "<leader>'", function()
			harpoon:list():select(6)
		end)
	end,
}
