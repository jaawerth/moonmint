local format = [[
package = "moonmint"
version = "%s"
source = {
    url = "file:////0.0.0.0%s"
}
description = {
    homepage = "https://github.com/bakpakin/moonmint",
    summary = "Express like web framework for Lua",
    license = "MIT",
}
dependencies = {
    "lua >= 5.1",
    "luv ~> 1.8",
    "luv-coro-channel >= 1.8",
    "luv-coro-net >= 1.8",
    "mimetypes >= 1.0",
    "bkopenssl >= 0.0",
    "bit32"
}
build = {
    type = "builtin",
    modules = {
        ["moonmint"] = "init.lua",

        ["moonmint.server"] = "src/server.lua",
        ["moonmint.static"] = "src/static.lua",
        ["moonmint.util"] = "src/util.lua",
        ["moonmint.router"] = "src/router.lua",
        ["moonmint.template"] = "src/template.lua",
        ["moonmint.fs"] = "src/fs.lua",
        ["moonmint.headers"] = "src/headers.lua",
        ["moonmint.request"] = "src/request.lua",
        ["moonmint.response"] = "src/response.lua",

        ["moonmint.deps.codec.http"] = "deps/codec/http.lua",
        ["moonmint.deps.codec.tls"] = "deps/codec/tls.lua",
        ["moonmint.deps.pathjoin"] = "deps/pathjoin.lua"
    }
}
]]

local currentDirectory = io.popen('pwd'):read'*l'
local version = 'local-0'
local target = ('moonmint-%s.rockspec'):format(version)

local f = assert(io.open(target, 'w'))
f:write(format:format(version, currentDirectory))
f:close();
print(('Wrote to %s.'):format(target))
