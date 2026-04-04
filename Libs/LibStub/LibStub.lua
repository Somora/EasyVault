local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 1
local LibStub = _G[LIBSTUB_MAJOR]

if not LibStub or LibStub.minor < LIBSTUB_MINOR then
    LibStub = LibStub or { libs = {}, minors = {} }
    _G[LIBSTUB_MAJOR] = LibStub
    LibStub.minor = LIBSTUB_MINOR

    function LibStub:NewLibrary(major, minor)
        assert(type(major) == "string", "Bad argument #2 to `NewLibrary` (string expected)")
        minor = assert(tonumber(minor), "Minor version must either be a number or convertible to a number")

        local oldMinor = self.minors[major]
        if oldMinor and oldMinor >= minor then
            return nil
        end

        self.minors[major] = minor

        if not self.libs[major] then
            self.libs[major] = {}
        end

        return self.libs[major], oldMinor
    end

    function LibStub:GetLibrary(major, silent)
        if not self.libs[major] and not silent then
            error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
        end

        return self.libs[major], self.minors[major]
    end

    function LibStub:IterateLibraries()
        return pairs(self.libs)
    end

    setmetatable(LibStub, {
        __call = function(self, major, silent)
            return self:GetLibrary(major, silent)
        end,
    })
end
