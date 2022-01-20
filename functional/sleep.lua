return function(uv)
	return function(delay)
		local thread = coroutine.running()
		local t = uv.new_timer()
		t:start(delay, 0, function()
			t:stop()
			t:close()
			return assert(coroutine.resume(thread))
		end)
		return coroutine.yield()
	end
end