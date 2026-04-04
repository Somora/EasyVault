local MAJOR, MINOR = "LibDataBroker-1.1", 4
local LibStub = _G.LibStub
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then
    return
end

lib.attributestorage = lib.attributestorage or {}
lib.namestorage = lib.namestorage or {}

local proxies = lib.proxies or {}
lib.proxies = proxies

local objectMetatable = {
    __index = function(self, key)
        return lib.attributestorage[self] and lib.attributestorage[self][key]
    end,
    __newindex = function(self, key, value)
        local attributes = lib.attributestorage[self]
        attributes[key] = value

        if lib.callbacks and lib.callbacks[key] then
            for _, callback in ipairs(lib.callbacks[key]) do
                callback(self, key, value)
            end
        end
    end,
}

lib.callbacks = lib.callbacks or {}

function lib:NewDataObject(name, dataobj)
    assert(type(name) == "string", "Name must be a string")
    assert(type(dataobj) == "table", "Data object must be a table")

    if self.namestorage[name] then
        return self.namestorage[name]
    end

    local proxy = {}
    self.attributestorage[proxy] = dataobj
    self.namestorage[name] = proxy
    proxies[name] = proxy

    return setmetatable(proxy, objectMetatable)
end

function lib:GetDataObjectByName(name)
    return self.namestorage[name]
end

function lib:DataObjectIterator()
    return pairs(self.namestorage)
end

function lib:RegisterAttributeCallback(attribute, callback)
    if type(callback) ~= "function" then
        return
    end

    self.callbacks[attribute] = self.callbacks[attribute] or {}
    table.insert(self.callbacks[attribute], callback)
end
