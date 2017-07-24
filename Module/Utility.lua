local Utility = {}

-- 列出对应作者和版本的所有Mod的连接
function modLinks(authorName, version)
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

-- 列出所有作者的对应版本的Mod的链接（目录样式）
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
            text = text .. modLinks(author['名称'], version)
        end
        if count > 0 then
            return text
        end
    end

    return ''
    
    -- return mw.text.jsonEncode({ queryResult = queryResult })
end


-- 用卡片样式展示Mod
function modCard(mod)
    local text = '<div class="ddl-item-card-holder">\n'
        .. '<div class="ddl-item-card-indicium">\n'
        .. (mod['适配版本'] == '0.17' and '<div class="ddl-item-card-indicium-latest"><i class="fa fa-check" aria-hidden="true"></i>A17</div>\n' or '')
        .. ((mod['翻译进度'] == '已内置' or mod['翻译进度'] == '无文本' ) and '<div class="ddl-item-card-indicium-intrans"><i class="fa fa-check" aria-hidden="true"></i>内置翻译</div>\n' or '')
        .. (mod['需要新档'] == '是' and '<div class="ddl-item-card-indicium-newsave"><i class="fa fa-history" aria-hidden="true"></i>需要新档</div>\n' or '')
        .. '</div>\n'
        .. '<div class="ddl-item-card">\n'
        .. '<div class="ddl-item-card-preview">'
        .. (mod['封面'] and ('[[file:' .. mod['封面'] .. '|240px|link=' .. mod['路径'] .. ']]') or ('[[' .. mod['路径'] .. '|<i class="fa fa-puzzle-piece fa-5x" aria-hidden="true"></i>]]'))
        .. '</div>\n'
        .. '<div class="ddl-item-card-link">'
        .. '[[' .. mod['路径'] .. '|' .. mod['英文名'] .. '<br/>' .. mod['中文名'] .. ']]'
        .. '</div>\n'
        .. '</div>\n'
        .. '</div>\n'
    
    return text

    -- return mw.text.jsonEncode({ mod = mod })
end

-- 按照更新日期、作者或译者列出Mod（卡片样式）
function Utility.modWrapper(frame)
    local category = frame and frame.args[1] or '更新日期'
    local name = frame and frame.args[2] or ''
    local filter = '[[' .. category .. '::~*"' .. name .. '"*]]'
    local sort, order
    local limit = 300
    if category == '更新日期' then
        filter = '[[更新日期::+]]'
        sort = '更新日期,Modification date'
        order = 'desc,desc'
        limit = 15
    elseif category == '作者' then
        sort = '适配版本,英文名'
        order = 'desc,asc'
    elseif category == '译者' then
        sort = '适配版本,作者,英文名'
        order = 'desc,asc,asc'
    end

    local queryResult = mw.smw.ask({
        '[[类型::Mod]]',
        -- '[[适配版本::+]]',
        filter,
        '?路径',
        '?适配版本',
        '?翻译进度',
        '?需要新档',
        '?封面',
        '?英文名',
        '?中文名',
        '?作者',
        sort = sort,
        order = order,
        mainlabel = '-',
        headers = 'hide',
        link = 'none',
        limit = limit
    })

    local text = ''
    for i, mod in pairs(queryResult) do
        text = text .. modCard(mod)
    end

    return text
end

return Utility