--- @sync entry

-- Matches any name not containing ".test." (yazi's regex engine has no lookahead).
local HIDE_TESTS = [[^([^.]|\.((t|te|tes)?\.)*([^.t]|t[^.e]|te[^.s]|tes[^.t]|test[^.]))*(\.((t|te|tes)?\.)*(t|te|tes|test)?)?$]]

return {
	entry = function()
		local query = cx.active.current.files.filter and "" or HIDE_TESTS
		ya.emit("filter_do", { query, done = true })
	end,
}
