
local PerformanceOutput = {}
PerformanceOutput.__index = PerformanceOutput

local prevTime = 0
local maxSavedFps = 30

local function createLayout(self)
        local group = display.newGroup()
		group.y = 5

        self.lua_mem = display.newText("0", 0, 0, "Helvetica", 12)
        self.memory = display.newText("0", 0, 0, "Helvetica", 12)
        self.framerate = display.newText("0", 0, 0, "Helvetica", 12)

        self.lua_mem.anchorX, self.lua_mem.anchorY = 0,0 
		self.lua_mem.y = 0

        self.memory.anchorX, self.memory.anchorY = 0,0
		self.memory.y = self.lua_mem.y + self.lua_mem.height

        self.framerate.anchorX, self.framerate.anchorY = 0,0
		self.framerate.y = self.memory.y + self.memory.height

        self.memory:setFillColor(1,1,1)
        self.framerate:setFillColor(1,1,1)

        group:insert(self.lua_mem)
        group:insert(self.memory)
        group:insert(self.framerate)

        return group
end

local function minElement(table)
        local min = nil
        for i = 1, #table do
                if(min == nil or table[i] < min) then min = table[i]; end
        end
        return min
end


local function getLabelUpdater(self)
        local lastFps = {}
        local lastFpsCounter = 1
        return function(event)
                local curTime = system.getTimer()
                local dt = curTime - prevTime
                prevTime = curTime

                local fps = math.floor(1000/dt)

                lastFps[lastFpsCounter] = fps
                lastFpsCounter = lastFpsCounter + 1
                if(lastFpsCounter > maxSavedFps) then lastFpsCounter = 1; end
                local minLastFps = minElement(lastFps)

                self.lua_mem.text = string.format("Mem: %4.2f %s", collectgarbage("count")/1024,'Mb')
                self.lua_mem.anchorX, self.lua_mem.anchorY = 0,0
                self.lua_mem.x = 0

                self.framerate.text = string.format("FPS %.0f (Min %.0f)", fps, minLastFps)
                self.framerate.anchorX, self.framerate.anchorY = 0,0
				self.framerate.x = 0

                self.memory.text = string.format("Tex: %.2fMB", (system.getInfo("textureMemoryUsed")/1000000))
                self.framerate.anchorX, self.framerate.anchorY = 0,0
				self.memory.x = 0

        end
end

local instance = nil
-- Singleton
function PerformanceOutput.new()
        if(instance ~= nil) then return instance; end
        local self = {}
        setmetatable(self, PerformanceOutput)

        self.group = createLayout(self)

        Runtime:addEventListener("enterFrame", getLabelUpdater(self))

        instance = self
        return self
end

return PerformanceOutput
