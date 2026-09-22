return {
	"stevearc/oil.nvim",
	-- Not lazy: lets oil replace netrw and open directories at startup
	lazy = false,
	opts = {
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
		},
		keymaps = {
			["q"] = "actions.close",
		},
	},
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
	},
}
