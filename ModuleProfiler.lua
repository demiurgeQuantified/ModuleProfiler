-- Copyright (c) albion 2023
-- A lua profiler that doesn't rely on the debug library, as it is not available in many environments.
-- You may use it for private use freely but must have permission to redistribute it.
-- If you have any issues or improvements, open an issue or PR at https://github.com/demiurgeQuantified/ModuleProfiler

local pairs = pairs
local getTime = os.time
local diffTime = os.difftime

local ModuleProfiler = {}

local profiles = {}
local NO_MODULE_MODULE = "No Module"
profiles[NO_MODULE_MODULE] = {}

local moduleHeader =
[[################################
#%-30s#
################################
Calls     |Time      |Average
]]
local functionFormat =
[[%-32s
%-10u|%-10f|%-10f
]]

---Returns a function wrapping func, recording its performance data into t
---@param func function
---@param t table
---@return function
---@nodiscard
local wrapFunction = function(func, t)
    return function(...)
        t.calls = t.calls + 1
        local startTime = getTime()
        local retval = func(...)
        t.time = t.time + diffTime(getTime(), startTime)
        return retval
    end
end

---Returns the default profile data
---@return table
---@nodiscard
local getDefaultData = function()
    return {
        calls = 0,
        time = 0,
    }
end

---Registers a module in the profiler
---If two modules are registered by the same name, the newest will overwrite all others.
---@param module table
---@param name string
ModuleProfiler.registerModule = function(module, name)
    local moduleData = {}
    for key, value in pairs(module) do
        if type(value) == "function" then
            local funcData = getDefaultData()
            module[key] = wrapFunction(value, funcData)
            moduleData[key] = funcData
        end
    end
    profiles[name] = moduleData
end

---Registers a single function in the profiler. The returned function must overwrite the original to actually profile it.
---It may be a good idea to add a suffix/prefix to name, as two functions with the same name will overwrite each other's data
---@param func function
---@param name string
---@return function
---@nodiscard
ModuleProfiler.registerFunction = function(func, name)
    local funcData = getDefaultData()
    profiles[NO_MODULE_MODULE][name] = funcData
    return wrapFunction(func, funcData)
end

---Resets all performance data.
ModuleProfiler.resetCounters = function()
    for _,data in pairs(profiles) do
        for key,_ in pairs(data) do
            data[key] = getDefaultData()
        end
    end
end

local sortByCalls = function(a, b)
    return a.data.calls > b.data.calls
end

---Prints out all performance data neatly formatted, and returns it
---@return string
ModuleProfiler.generateReadout = function()
    local readout = ""
    for moduleName, moduleData in pairs(profiles) do
        readout = readout .. string.format(moduleHeader, moduleName)
        
        local sortedData = {}
        for funcName,funcData in pairs(moduleData) do
            table.insert(sortedData, {name=funcName, data=funcData})
        end
        table.sort(sortedData, sortByCalls)
        
        for i = 1, #sortedData do
            local funcData = sortedData[i]
            local stats = funcData.data
            readout = readout .. string.format(functionFormat, funcData.name, stats.calls, stats.time, stats.time / stats.calls)
        end
    end
    return readout
end

return ModuleProfiler