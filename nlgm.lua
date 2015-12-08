--
-- NLGM (Nginx Lua GraphicsMagick)
--
-- Nginx通过Lua脚本调用GraphicsMagick类库动态处理图片
--
-- /t_s160x80_q80_m1/27/ba/12345678.jpg
--
-- User: Eagle <0x07de@gmail.com>
-- Date: 15/10/23 14:56
--

local root = ngx.var.root

-- 字符串分割函数
-- 传入字符串和分隔符，返回分割后的table
function string.split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end

    return result
end

-- Table 包含
-- 遍历 Table 是否包含 element 元素
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end

    return false
end

-- 生成唯一文件名称
function generateUniqueFilename()
    local md5_str = ngx.md5(ngx.var.uri)
    --    ngx.say('URI md5:' .. md5_str)
    local ext = string.match(ngx.var.uri, ".[%a]+$")
    --    ngx.say(ext)

    ngx.header['T-UUID'] = md5_str -- 设置 Header 头

    return md5_str .. ext
end

-- 获取参数串段前缀
function getArgsStrPrefix()
    local args_prefix = 't_'
    if type(ngx.var.args_prefix) == "string" then
        args_prefix = ngx.var.args_prefix
    end

    return args_prefix
end

-- 获取缩略图目录
function getThumbnailUri()
    local thumbnail_dir = '/thumbnail/'
    if type(ngx.var.thumbnail_dir) == "string" then
        thumbnail_dir = ngx.var.thumbnail_dir
    end

    return thumbnail_dir .. generateUniqueFilename()
end

local args_str = string.match(ngx.unescape_uri(ngx.var.uri), "/" .. getArgsStrPrefix() .. "([^/]+)")

-- 获取处理图片参数表
function getArgsTable()
    local args_table = {};

    if args_str == nil or args_str == '' then
        return args_table
    end

    local args = string.split(args_str, '_')

    for _, str in pairs(args) do
        local key = string.sub(str, 1, 1)
        args_table[key] = string.sub(str, 2, string.len(str))
    end

    return args_table
end

-- 获取源文件路径
function getSourceFilepath()

    if args_str == nil or args_str == '' then
        return ngx.var.uri
    end

    local pos = string.find(ngx.var.uri, args_str)

    --    ngx.say("字符串位置:" .. pos)

    return root .. string.sub(ngx.var.uri, pos + string.len(args_str), -1)
end

-- 是不是文件
function fileExists(name)
    if type(name) ~= "string" then return false end
    return os.rename(name, name) and true or false
end

-- URL参数表
local args_table = getArgsTable()
-- 命令参数选项 最终会组合成字符串
local options = {}

-- 质量
if args_table.q then
    local quality = tonumber(args_table.q);
    if quality > 0 and quality <= 100 then
        table.insert(options, "-quality " .. quality)
    end
end


-- 获取尺寸
function getSize(size_str)
    local width, height, _

    --格式 20x30
    _, _, width, height = string.find(size_str, "^(%d+)x(%d+)$")
    if width ~= nil then
        return width, height
    end

    --格式 20x
    _, _, width = string.find(size_str, "^(%d+)x$")
    if (width ~= nil) then
        return width, ''
    end

    --格式 x20
    _, _, height = string.find(size_str, "^x(%d+)$")
    if height ~= nil then
        return '', height
    end

    -- 格式 20 正方形
    _, _, width = string.find(size_str, "^(%d+)$")
    if width ~= nil then
        return width, width
    end

    return nil, nil
end

if type(args_table.s) == "string" and args_table.s ~= '' then

    local size_width, size_height = getSize(args_table.s)
    if size_width ~= nil and size_height ~= nil then

        local size_str = size_width .. 'x' .. size_height;

        -- 裁剪模式
        if args_table.m then
            local mode = tonumber(args_table.m)

            if mode == 1 then
                size_str = size_str .. '!' -- 强制宽高
            elseif mode == 2 then
                size_str = size_str .. '^' -- 高度强制  宽度自动
            elseif mode == 3 then
                size_str = '^' .. size_str -- 宽度强制  高度自动
            end
        end

        table.insert(options, '-geometry "' .. size_str .. '>"')
    end
end

-- ngx.say(table.concat(options, ' '))

local source_file = getSourceFilepath()
local thumbnail_uri = getThumbnailUri()
local taget_file = root .. thumbnail_uri

-- 源文件不存在
if fileExists(source_file) ~= true then
    ngx.exit(404)
end

-- 目标文件已经存在 直接 rewrite
if fileExists(taget_file) then
    ngx.header['T-Generate'] = '0'
    ngx.req.set_uri(thumbnail_uri, true)
    return
end

-- gm 命令目录
local gm_bin = "/usr/local/bin/gm"
if ngx.var.gm_bin then
    gm_bin = ngx.var.gm_bin
end

local cmd = ''
--pack command:local cmd
if args_table.benchmark then
    cmd = gm_bin .. ' benchmark convert '
else
    cmd = gm_bin .. ' convert '
end

-- 默认选项
local default_options = ' -interlace plane +profile "*" '

cmd = cmd .. '"' .. source_file .. '" ' .. default_options .. ' ' .. table.concat(options, ' ') .. ' "' .. taget_file .. '"'

-- exec command:
if args_table.v then
    ngx.say(cmd)
else
    local ret = os.execute(cmd)
    -- ngx.say('返回值：' .. ret)

    ngx.header['T-Generate'] = '1'
    ngx.req.set_uri(thumbnail_uri, true)
end
