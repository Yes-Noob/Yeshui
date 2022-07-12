Projectile = {
    TYPE = "TYPE_PROJECTILE",
    ITEM = 4098,
    ID = 4097,
    ONCE = 18,
    NUM = 36,
    TICK = 130,
    Prepearing = false,
    Num = 0,
    Err = false,
    ReadNum = {},
    InitNum = {}
}

--[[
 玩家释放万剑归宗技能
 @use    发出剑锋，使万剑归宗开始
 @value  {
    player: 归属玩家ID
    itemid: 目前投掷物ID
    x:      目前的x
    y:      目前的y
    z:      目前的z
    yaw:    绝对横向角度
    pitch:  绝对纵向角度
    state:  层级
    tox:    投掷物目标地点x
    toy:    投掷物目标地点y
    toz:    投掷物目标地点z
    life:   是否被登记完成，用于快速调试
    way:    投掷物路径
 }
--]]
function Projectile.StartONCE(event)
    if (event.itemid == Projectile.ITEM) then
        if (Projectile.Prepearing == false) then
            Projectile.Prepearing = true
            Projectile.Num = Projectile.Num + 1
            Projectile[Projectile.Num] = {}
            Projectile.InitNum[#Projectile] = 0
            for i = 1, Projectile.NUM do
                local deg = 360 / Projectile.ONCE * i
                local result, id, yaw, pitch
                if (i % 2 == 0) then
                    local result, x, y, z = Actor:getPosition(event.eventobjid)
                    local x1, y1, z1 = Math:getDreByBallInActor(event.eventobjid, deg, 0)
                    result, id = World:spawnProjectile(event.eventobjid, Projectile.ID, x, y + 0.6, z, x1, y1, z1, 50)
                    yaw, pitch = deg, 0
                else
                    local result, x, y, z = Actor:getPosition(event.eventobjid)
                    local x1, y1, z1 = Math:getDreByBallInActor(event.eventobjid, deg, 30)
                    result, id = World:spawnProjectile(event.eventobjid, Projectile.ID, x, y + 0.6, z, x1, y1, z1, 50)
                    yaw, pitch = deg, 30
                end
                ----- 我的身份 -----
                local index = Projectile.Num
                Projectile[index][#Projectile[index] + 1] = {}
                local nowIndex = Projectile[index][#Projectile[index]]
                ----- 我是谁 -----
                nowIndex.player = event.eventobjid -- Static Value
                nowIndex.itemid = id -- Dynamic Value
                ----- 我去哪 -----
                nowIndex.yaw = yaw -- Dynamic Value
                nowIndex.pitch = pitch -- Dynamic Value
                local x, y, z = Math:getDreByBallInPos({event.x, event.y, event.z}, nowIndex.yaw, nowIndex.pitch, 0, 0)
                nowIndex.tox = x -- Dynamic Value
                nowIndex.toy = y -- Dynamic Value
                nowIndex.toz = z -- Dynamic Value
                -----------[=[ 一切准备就绪后，开始运行生命周期 ]=]-----------
                local me = nowIndex.player or nowIndex.itemid
                local pos = nowIndex.x or nowIndex.y or nowIndex.z
                local face = nowIndex.yaw or nowIndex.pitch or nowIndex.state
                local to = nowIndex.tox or nowIndex.toy or nowIndex.toz
                local bool = me or pos or face or to
                local n = nowIndex
                if (bool == true) then
                    print("------ 记录了一个投掷物 ------> > " .. #Projectile[index])
                    nowIndex.life = true
                    Projectile.Err = false
                    nowIndex.way = Projectile.paint()
                    Trigger:wait(0.05)
                    for i = 1, 130 do
                        World:despawnActor(nowIndex.id)
                        local result, x, y, z = Actor:getPosition(nowIndex.id)
                        local x, y, z = Math:getDreByBallInPos({x, y, z}, nowIndex.yaw, nowIndex.pitch, 0, 0)
                        nowIndex.tox = x
                        nowIndex.toy = y
                        nowIndex.toz = z
                        local result, x, y, z = Actor:getPosition(nowIndex.id)
                        local tox, toy, toz = nowIndex.tox, nowIndex.toy, nowIndex.toz
                        local result, id = World:spawnProjectile(nowIndex.player, Projectile.ID, x, y, z, tox, toy, toz,
                            nowIndex.way[i].speed)
                        nowIndex.id = id
                        nowIndex.yaw = nowIndex.yaw + nowIndex.way[i].yaw
                        Trigger:wait(0.05)
                    end
                else
                    print("#cff0000------ 投掷物信息错误！ ------> > " .. #Projectile[index])
                    local booltb = {me, pos, face, to}
                    for k, v in pairs(booltb) do
                        if (v == false) then
                            print("|" .. k .. "有错误|")
                        end
                    end
                    nowIndex.life = false
                    Projectile.Err = true
                end
            end
        else
            local msg = "#G万剑归宗冷却中"
            Player:notifyGameInfo2Self(event.eventobjid, msg)
        end
    end
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], Projectile.StartONCE)

--[[
 绘制投掷物的路径
 @use    模拟投掷物时间：旋转度数的路径
 ------- 虽不知道投掷物的秒速，但可以纪录旋转
 @param  index: 投掷物索引
 @value  {
     face:  yaw_pitch/s
     yaw:   偏移的横向量
     pitch: 偏移的纵向量
 }
--]]
function Projectile.paint()
    local alltime = 130 -- tick
    local face = {} -- table
    ------[=[ 第一阶段：直线飞行 ]=]------
    local num = 5
    for i = 1, num do
        if (i >= 1 and i <= 5) then
            local yaw, speed = 0, 60 -- 旋转10
            table.insert(face, {yaw, speed})
        end
    end
    ------[=[ 第二阶段：螺旋飞行 ]=]------
    local num = 75
    for i = 1, num do
        if (i >= 1 and i <= 5) then
            local yaw, speed = 18, 60
            table.insert(face, {yaw, speed})
        elseif (i > 5 and i <= 15) then
            local yaw, speed = 9, 60
            table.insert(face, {yaw, speed})
        elseif (i > 15 and i <= 25) then
            local yaw, speed = 9, 120
            table.insert(face, {yaw, speed})
        elseif (i > 25 and i <= 35) then
            local yaw, speed = 4.5, 240
            table.insert(face, {yaw, speed})
        elseif (i > 35 and i <= 55) then
            local yaw, speed = 2.25, 240
            table.insert(face, {yaw, speed})
        end
    end
    ------[=[ 第三阶段：旋转飞行 ]=]------
    local num = 50
    for i = 1, num do
        if (i >= 1 and i <= 50) then
            local yaw, speed = 4.5, 240
            table.insert(face, {yaw, speed})
        end
    end
    ------[=[ 第四阶段：万剑归宗 ]=]------
    return face
end
