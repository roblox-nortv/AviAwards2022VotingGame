local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
Knit.AddControllersDeep(script.Parent:WaitForChild("Controllers"))

-- Start Knit:
local startTime = os.clock()
Knit.Start({ ServicePromises = false })
	:catch(function(err)
		warn("Knit framework failure: " .. tostring(err))
	end)
	:andThen(function()
		warn("[Client] Knit framework started in " .. tostring(os.clock() - startTime) .. " seconds")
	end)
