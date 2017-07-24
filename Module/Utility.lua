local Utility = {}

-- 列出对应作者和版本的所有Mod的连接
function modLink(authorName, version)
    if authorName == nil or authorName == '' then
        return ''
    end

    local queryResult = mw.smw.ask({
        '[[类型::Mod]]',
        '[[作者::~*"' .. authorName .. '"*]]',
        '[[适配版本::~*' .. version .. '*]]',
        '?路径',
        '?英文名',
        '?中文名',
        sort = '路径',
        mainlabel = '-',
        headers = 'hide',
        link = 'none',
        limit = 300
    })
    if type(queryResult) == 'table' then
        local text = '<div class="ddl-color-stick"></div>\n<h2 class="ddl-works-category">' .. authorName .. '</h2>\n<div class="ddl-list-link">\n'
        local count = 0
        for i, mod in pairs(queryResult) do
            count = i
            text = text .. '[[' .. mod['路径'] .. '|' .. mod['英文名'] .. ' - ' .. mod['中文名'] .. ']]\n'
        end
        text = text .. '</div>\n'
        if count > 0 then
            return text
        end
    end

    return ''

    -- return mw.text.jsonEncode({ authorName = authorName, version = version, queryResult = queryResult })
end

-- 列出所有作者的对应版本的Mod的连接
function Utility.modIndex(frame)
    local version = frame and frame.args[1] or '0.17'

    local queryResult = mw.smw.ask({
        '[[类型::~*"作者"*]]',
        '?名称',
        sort = '排序',
        mainlabel = '-',
        headers = 'hide',
        link = 'none',
        limit = 300
    })
    if type(queryResult) == 'table' then
        local text = ''
        local count = 0
        for i, author in pairs(queryResult) do
            count = i
            text = text .. modLink(author['名称'], version)
        end
        if count > 0 then
            return text
        end
    end

    return ''
    
    -- return mw.text.jsonEncode({ queryResult = queryResult })
end

return Utility