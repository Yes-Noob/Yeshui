Projectile = {
    TYPE       = "TYPE_PROJECTILE",
    ITEM       = 4098,
    ID         = 4097,
    ONCE       = 18,
    NUM        = 36,
    TICK       = 130,
    Prepearing = false,
    Num        = 0,
    Err        = false,
    ReadNum    = {},
    InitNum    = {},
}

--[[
 玩家释放万剑归宗技能
 @use    发出剑锋，使万剑归宗开始
 @value  {
     prepearing: 开启准备键
 }
--]]
function Projectile.StartONCE(event)
    if (event.itemid==Projectile.ITEM) then
        if (Projectile.Prepearing==false) then
            Projectile.Prepearing = true
            Projectile.Num = Projectile.Num+1
            Projectile[Projectile.Num] = {}
            Projectile.InitNum[#Projectile] = 0
            for i = 1, Projectile.ONCE do
                local deg = 360/Projectile.ONCE*i
                if (i%2==0) then
                local result, x, y, z = Actor:getPosition(event.eventobjid)
                local x1, y1, z1 = Math:getDreByBallInActor(event.eventobjid, deg, 0)
                local result, id = World:spawnProjectile(event.eventobjid, Projectile.ID, x, y+0.6, z, x1, y1, z1, 50)
                ----- 我的身份 -----
                local index     = Projectile.Num
                Projectile[index][#Projectile[index]+1] = {}
                local nowIndex  = Projectile[index][#Projectile[index]]
                ----- 我是谁 -----
                nowIndex.player = event.eventobjid --Static Value
                nowIndex.itemid = id --Dynamic Value
                            ----- 我在哪 -----
                            nowIndex.x      = event.x --Dynamic Value
                            nowIndex.y      = event.y --Dynamic Value
                            nowIndex.z      = event.z --Dynamic Value
                            ----- 我去哪 -----
                            if (#Projectile[index]%2==1) then --如果是奇数
                                nowIndex.yaw    = (360/Projectile.ONCE)*((#Projectile[index]-1)/2) --Dynamic Value
                                nowIndex.pitch  = 0 --Dynamic Value
                                nowIndex.state  = 1 --Static Value
                            else --如果是偶数
                                nowIndex.yaw    = (360/Projectile.ONCE)*((#Projectile[index])/2) --Dynamic Value
                                nowIndex.pitch  = 30 --Dynamic Value
                                nowIndex.state  = 2 --Static Value
                            end
                            local x, y, z   = Math:getDreByBallInPos({event.x, event.y, event.z}, nowIndex.yaw, nowIndex.pitch, 0, 0)
                            nowIndex.tox    = x --Dynamic Value
                            nowIndex.toy    = y --Dynamic Value
                            nowIndex.toz    = z --Dynamic Value
                            -----------[=[ 一切准备就绪后，开始运行生命周期 ]=]-----------
                            local me   = nowIndex.player or nowIndex.itemid
                            local pos  = nowIndex.x or nowIndex.y or nowIndex.z
                            local face = nowIndex.yaw or nowIndex.pitch or nowIndex.state
                            local to   = nowIndex.tox or nowIndex.toy or nowIndex.toz
                            local bool = me or pos or face or to
                            local n    = nowIndex
                            if (bool==true) then
                                print("------ 记录了一个投掷物 ------> > "..#Projectile[index])
                                nowIndex.life  = true
                                Projectile.Err = false
                                nowIndex.way   = Projectile.paint()
                            else
                                print("#cff0000------ 投掷物信息错误！ ------> > "..#Projectile[index])
                                local booltb = {me, pos, face, to}
                                for k, v in pairs(booltb) do
                                    if (v==false) then
                                        print("|"..k.."有错误|")
                                    end
                                end
                                nowIndex.life  = false
                                Projectile.Err = true
                
            end
            
        else
            local msg = "#G万剑归宗冷却中"
            Player:notifyGameInfo2Self(event.eventobjid, msg)
        end
    end
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], Projectile.StartONCE)

--[[
 登记万剑归宗投掷物
 @use    为万剑归宗做好准备
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
function Projectile.Register(event)
    if (Projectile.Propearing==true) then
        if (event.itemid==Projectile.ITEM) then
        end
    end
end
ScriptSupportEvent:registerEvent([=[Missle.Create]=], Projectile.Register)

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
    local alltime = 130 --tick
    local face    = {}  --table
    ------[=[ 第一阶段：直线飞行 ]=]------
    local num = 5
    for i = 1, num do
        if (i>=1 and i<=5) then
            local yaw, speed = 0, 60 --旋转10
            table.insert(face, {yaw, speed})
        end
    end
    ------[=[ 第二阶段：螺旋飞行 ]=]------
    local num = 75
    for i = 1, num do
        if (i>=1 and i<=5) then
            local yaw, speed = 18, 60
            table.insert(face, {yaw, speed})
        elseif (i>5 and i<=15) then
            local yaw, speed = 9, 60
            table.insert(face, {yaw, speed})
        elseif (i>15 and i<=25) then
            local yaw, speed = 9, 120
            table.insert(face, {yaw, speed})
        elseif (i>25 and i<=35) then
            local yaw, speed = 4.5, 240
            table.insert(face, {yaw, speed})
        elseif (i>35 and i<=55) then
            local yaw, speed = 2.25, 240
            table.insert(face, {yaw, speed})
        end
    end
    ------[=[ 第三阶段：旋转飞行 ]=]------
    local num = 50
    for i = 1, num do
        if (i>=1 and i<=50) then
            local yaw, speed = 4.5, 240
            table.insert(face, {yaw, speed})
        end
    end
    ------[=[ 第四阶段：万剑归宗 ]=]------
    return face
end

--[[
 让投掷物跑起来
 @use    运行投掷物
 @param  event
 @athor  Projectile/1/data
--]]
function Projectile.runProjectile(event)
    local self = Projectile
    if (self.Num==0) then return end
    if (self.Err==true) then return end
    for i = 1, #self do --防止玩家同时使用太多而卡bug
        local nowIndex = self[i] --Projectile的key
        for i_ = 1, self.ONCE do
            local nowIndex = nowIndex[i_] --Projectile的所在地
            self.ReadNum[#self] = self.ReadNum[#self] or 0
            self.ReadNum[#self] = self.ReadNum[#self]+1
            local pos = {nowIndex.x, nowIndex.y, nowIndex.z}
            local yaw, pitch = nowIndex.yaw, nowIndex.pitch
            local desyaw, despitch = nowIndex.way[self.ReadNum[#self]].yaw, 0
            local x, y, z = Math:getDreByBallInPos(pos, yaw, pitch, desyaw, despitch)
            if (x and y and z) then
                local x, y, z = x, y, z --目的地
                local result, px, py, pz = Actor:getPosition(nowIndex.itemid)
                local result = World:despawnActor(nowIndex.itemid)
                local result = World:spawnProjectile(0, Projectile.ID, px, py, pz, x, y, z, nowIndex.way[self.ReadNum[#self]].speed)
                if (result==1001) then print("#cff0000ERRORCODE: ", x, y, z) end
            else
                print("#cff0000ERROR  ", pos, yaw, pitch, desyaw)
            end nowIndex.id = false
        end
    end
end
--ScriptSupportEvent:registerEvent([=[Game.Run]=], Projectile.runProjectile)

--[[
 刷新投掷物ID
 @use  刷新投掷物ID
 @param  event
--]]
function Projectile.renew(event)
    for i = 1, #Projectile do
        Projectile.InitNum[i] = Projectile[i].InitNum+1
        Projectile[Projectile.InitNum[i]].itemid = event.toobjid
    end
end
ScriptSupportEvent:registerEvent([=[Missle.Create]=], Projectile.renew)
