if vim.version().minor < 10 then
	vim.api.nvim_err_writeln('zmk requires at least nvim v0.10')
	return
end

-- make sure this file is loaded only once
if vim.g.loaded_zmk == 1 then
	return
end
vim.g.loaded_zmk = 1
