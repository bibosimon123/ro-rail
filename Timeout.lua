do
	RAIL.Timeouts = Table:New()

	local Timeout = { }

	local metatable = {
		__index = Timeout
	}

	Timeout.Update = function(self)
		if not self[1] then
			-- Not active; do nothing
			return self
		end

		-- Check if the timeout should fire
		local delta = GetTick() - (self[2]+self[3])
		if delta >= 0 then
			-- Fire the callback
			self[5](self[6],delta)

			if not self[4] then
				-- Not repeating, so set the active element to false
				self[1] = false
			else
				-- Repeating, so reset the base time
				self[2] = GetTick()
			end
		end

		return self
	end

	RAIL.Timeouts.New = function(self,duration,repeating,callback,callback_arg)
		local ret = { true, GetTick(), duration, repeating, callback, callback_arg }
		setmetatable(ret,metatable)

		self:Insert(ret)

		return ret
	end

	RAIL.Timeouts.Iterate = function(self)
		local k = 0
		for i=1,self:GetN() do
			-- Update the timeout, then check if it's still active
			if self[i]:Update()[1] == true then
				-- Since it's still active, keep it in the table
				k = k + 1
				self[k] = self[i]
			end
		end

		-- Set the new size, after timeouts have been removed
		self:SetN(k)
	end
end