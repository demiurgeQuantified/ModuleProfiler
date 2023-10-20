A Lua profiler that doesn't rely on the debug library, intended for environments where it is not available.
## Usage
First, pull the ModuleProfiler module into your file:
```lua
local ModuleProfiler = require "ModuleProfiler" -- this should be the path to the ModuleProfiler file
```
You can register an entire module using ``registerModule``:
```lua
ModuleProfiler.registerModule(MyModule, "MyModuleName")
```
If you're not using a module or don't want to profile the entire thing, you can register individual functions with ``registerFunction``. It will appear in the readout under 'No Module'.
```lua
myFunc = ModuleProfiler.registerFunction(myFunc, "myFuncName")
```
The returned function must overwrite the original in any places it appears.

Note that in both cases, the names must be unique - newly passed data will overwrite another module/function registered under the same name.

To get the profile data, use ``generateReadout()``.
```lua
local readout = ModuleProfiler.generateReadout()
-- in most cases, you just want to print it
print(readout)
```
