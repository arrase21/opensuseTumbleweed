-- 1. LSP Autoformat (Optimizado)
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP autoformat setup",
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		-- Seguridad: solo si el cliente existe y tiene capacidad de formateo
		if not (client and client.server_capabilities.documentFormattingProvider) then
			return
		end

		local bufnr = event.buf
		local group = vim.api.nvim_create_augroup("lsp_autoformat_" .. bufnr, { clear = true })

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = group,
			buffer = bufnr,
			desc = "Format before save",
			callback = function()
				vim.lsp.buf.format({
					bufnr = bufnr,
					async = false, -- Obligatorio para que guarde DESPUÉS de formatear
					timeout_ms = 1000, -- 10s era demasiado, 2s es más que suficiente
				})
			end,
		})
	end,
})

-- 2. Yank Highlight (Limpio)
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = "Highlight text on yank",
	group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			higroup = 'IncSearch',
			timeout = 150, -- Duración del flash en ms
		})
	end,
})

-- 3. Fix Format Options (Con grupo para evitar leaks)
vim.api.nvim_create_autocmd("FileType", {
	desc = "Disable automatic comment continuation",
	group = vim.api.nvim_create_augroup("FixFormatOptions", { clear = true }),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end
})

-- vim.api.nvim_create_autocmd('FileType', {
-- 	pattern = { 'go', 'lua', 'python', 'http' },
-- 	callback = function()
-- 		if pcall(vim.treesitter.start) then
-- 			vim.treesitter.start()
-- 		end
-- 	end,
-- })
