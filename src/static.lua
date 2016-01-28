local mime = require('mime').getType
local hybridfs = require 'hybrid-fs'
local byte = string.byte
local setmetatable = setmetatable
local match = string.match

local function makeCacheEntry(fs, path, stat)
    local body = fs.readFile(path)
    if not body then return nil end
    return {
        path = path,
        mime = mime(path),
        body = body,
        time = stat.mtime
    }
end

local Static = {}
local Static_mt = {
    __index = Static
}

function Static:doRoute(req, res)

    if req.method ~= "GET" then return end
    local path = match(req.path, "/?([^%?%#]*)")
    if not path or #path == 0 then
        path = "./"
    end

    local fs = self.fs
    local cache = self.cache
    local nocache = self.nocache

    local stat = fs.stat(path)
    if not stat then return end

    if stat.type == "directory" then
        if byte(path, -1) == 47 then
            path = path .. "index.html"
        else
            path = path .. "/index.html"
        end
        stat = fs.stat(path);
        if not stat then return end
    end

    local cachedResponse = cache[path]

    if cachedResponse and cachedResponse.time == stat.mtime then
        res.code = 200
        res.body = cachedResponse.body
        res.mime = cachedResponse.mime
    else
        cachedResponse = makeCacheEntry(fs, path, stat)
        if not cachedResponse then
            return
        end
        if not nocache then cache[path] = cachedResponse end
        res.code = 200
        res.body = cachedResponse.body
        res.mime = cachedResponse.mime
    end
    res:send()
end

Static_mt.__call = Static.doRoute

function Static:clearCache()
    self.cache = {}
end

return function(base, nocache)
    return setmetatable({
        fs = hybridfs(base),
        cache = {},
        nocache = nocache
    }, Static_mt)
end