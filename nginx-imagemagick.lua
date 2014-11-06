-- http://domain.com/cdn_assets/photo/201411/05/5459e306820af926411357_320x320.jpg

-- config
local image_sizes = { "640x640", "320x320", "124x124", "140x140", "64x64", "60x60", "32x32" }


-- parse uri
function parseUri(uri)
    local _, _, name, size, ext = string.find(uri, "(.+)_(%d+x%d+)(%..+)")
    if name and size and ext then
        return ngx.var.image_root .. name .. ext, size
    else
        return "",""
    end
end

function fileExists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function sizeExists(size)
    for _, value in pairs(image_sizes) do
        if value == size then
            return true
        end
    end

    return false
end

function resize()
    local ori_filename, szie = parseUri(ngx.var.uri)
    if fileExists(ori_filename) == false or sizeExists(szie) == false then
        ngx.exit(404)
    end

    local command = table.concat({
        ngx.var.convert_bin,
        ori_filename,
        "-thumbnail",
        szie .. "^",
        "-quality 85 -gravity center -extent",
        szie,
        ngx.var.file,
    }, " ")
    os.execute(command)
end

resize()
