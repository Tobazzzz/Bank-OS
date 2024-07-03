--ATM version 0.0.7--
--Must be startup program--

--Vars--

local atm = "atm_1"
local drive = "bottom"

local backColor = colors.black
local screen = 0
local pinMode = false
local depMode = false
local withMode = false
local trasMode = false
local accMode = false
local escs = false
local cashMode = false
local pad = ""


local done = {24, 12, 28, "#done"}
local buttons1 = {
    {16, 8, 23, "#balance"}, --button X, Y || buttonLength || buttonText--
    {28, 8, 35, "#deposit"},
    {16, 10, 24, "#withdraw"},
    {28, 10, 36, "#tranfers"}
}

--Vars--

--Functions--
function pinpadClick(key)
    if (tonumber(key)) then
        if tonumber(key) == 259 then
            return true, 10
        elseif tonumber(key) == 257 then
            return true, 11
        elseif tonumber(key) >= 0 and tonumber(key) <= 9 then
            return true, tonumber(key)
        end
    end
    return false
end

function pinClick(clk, name)
    if clk == 11 then
        if (pinMode) then
            if string.len(pad) == 5 then
                return true, pad
            end
        else
            if string.len(pad) < 6 then
                return true, pad
            end
        end
    elseif clk == 10 then
        term.setCursorPos(21, 8)
        term.clearLine()
        term.write(name)
        pad = string.sub(pad, 1, string.len(pad) -1)
        if (pinMode) then
            term.write(string.sub("****", 1, string.len(pad)))
        else
            term.write(pad)
        end
    else
        if (string.len(pad) < 5) then
            pad = pad.. clk
            term.setCursorPos(26, 8)
            if (pinMode) then
                term.write(string.sub("*****", 1, string.len(pad)))
            else
                term.write(pad)
            end
        end
    end
    return false   
end

function drawScreen(scrn)
    api.clear(backColor, true)
    if scrn == 0 then
        api.clear(backColor, false)
        screen = 0
        term.setCursorPos(17, 9)
        term.write("Please insert card")
    elseif scrn == 1 then
        screen = 1
        for k, v in pairs(buttons1) do
            term.setCursorPos(buttons1[k][1], buttons1[k][2])
            term.write(buttons1[k][4])
        end
    elseif scrn == 2 then
        screen = 2
        term.setCursorPos(17, 5)
        term.write("Please enter your pin")
        term.setCursorPos(21, 8)
        term.setBackgroundColor(backColor)
        term.setTextColor(colors.lightGray)
        term.write("Pin: ")
        pinMode = true
        pad = ""
    elseif scrn == 3 then
        screen = 3
        term.setCursorPos(10, 5)
        term.write("Please insert diamonds then click done")
        term.setCursorPos(done[1], done[2])
        term.write(done[4])
        depMode = true
    elseif scrn == 4 then
        screen = 4
        term.setCursorPos(4, 5)
        term.write("Please enter the ammount you want to withdraw")
        term.setCursorPos(21, 8)
        term.setBackgroundColor(backColor)
        term.setTextColor(colors.lightGray)
        term.write("Amm: ")
        withMode = true
        pad = ""
    elseif scrn == 5 then
        screen = 5
        term.setCursorPos(4, 5)
        term.write("Please enter the ammount you want to transfer")
        term.setCursorPos(21, 8)
        term.setBackgroundColor(backColor)
        term.setTextColor(colors.lightGray)
        term.write("Amm: ")
        trasMode = true
        pad = ""
    elseif scrn == 6 then
        screen = 6
        term.setCursorPos(20, 9)
        term.write("Settings screen")
    end
end
        

function onClick(cX, cY, key)
    if screen == 1 then
        if (backBut(cX, cY)) then
            return true, 999
        end
        for k, v in pairs(buttons1) do
            if (cX >= buttons1[k][1] and cX <= buttons1[k][3] and cY == buttons1[k][2]) then
                return true, k
            end
        end
    elseif screen == 2 then
        if (backBut(cX, cY)) then
            return true, 100
        end
        if (pinMode) then
            return pinpadClick(key)
        end
    elseif screen == 3 then
        if (backBut(cX, cY)) then
            if (pinMode) then
                return true, 200
            else
                return true, 100
            end
        end
        if (depMode) then
            if (cX >= done[1] and cX <= done[3] and cY == done[2]) then
                return true, 300
            end
        end
        if (pinMode) then
            return pinpadClick(key)
        end
    elseif screen == 4 then
        if (backBut(cX, cY)) then
            return true, 100
        end
        if (withMode or pinMode) then
            return pinpadClick(key)
        end
    elseif screen == 5 then
        if (backBut(cX, cY)) then
            return true, 100
        end
        if (trasMode or accMode or pinMode) then
            return pinpadClick(key)
        end
    elseif screen == 6 then
        if (backBut(cX, cY)) then
            return true, 999
        end
    end
    return false
end

function backBut(bX, bY)
    if (bX == 49 and bY == 17) then
        return true
    end
end


function prosClick(butt)
    if screen == 1 then
        if butt == 999 then
            drawScreen(0)
            disk.eject(drive)
        elseif butt == 1 then
            drawScreen(2)
        elseif butt == 2 then
            drawScreen(3)
        elseif butt == 3 then
            drawScreen(4)
        elseif butt == 4 then
            --drawScreen(5)
        end
    elseif screen == 2 then
        if butt == 100 then
            pinMode = false
            drawScreen(1)
        end
        if (pinMode) then
            local isBPin, bPin = pinClick(butt, "Pin: ")
            if (isBPin) then
                pinMode = false
                api.clear(backColor, false)
                term.setCursorPos(17, 9)
                term.write("Retrieving your balance...")
                local isBal, bal = api.balance(acc, atm, bPin)
                api.clear(backColor, true)
                term.setCursorPos(17, 9)
                term.write("Your balance: ")
                term.write(bal)
            end
        end
    elseif screen == 3 then
        if butt == 100 then
            depMode = false
            pinMode = false
            drawScreen(1)
        elseif butt == 200 then
            pullapi.withdraw(dep)
            depMode = false
            pinMode = false
            escs = false
            drawScreen(1)
        end
        if (depMode) then
            if butt == 300 then
                depMode = false
                isDep, dep = pullapi.deposit()
                if (isDep) then
                    api.clear(backColor, true)
                    term.setCursorPos(17, 5)
                    term.write("Please enter your pin")
                    term.setCursorPos(21, 8)
                    term.setBackgroundColor(backColor)
                    term.setTextColor(colors.lightGray)
                    pinMode = true
                    escs = true
                    term.write("Pin: ")
                    pad = ""
                else
                    api.clear(backColor, true)
                    term.setCursorPos(10, 5)
                    term.write(dep)
                end
            end
        elseif (pinMode) then
            local isDPin, dPin = pinClick(butt, "Pin: ")
            if (isDPin) then
                pinMode = false
                escs = false
                api.clear(backColor, false)
                term.setCursorPos(17, 9)
                term.write("Depositing $")
                term.write(dep)
                term.write(" to you account..")
                local isDep, dep2 = api.deposit(acc, dep, atm, dPin)
                api.clear(backColor, true)
                term.setCursorPos(17, 9)
                if (isDep) then
                    term.write("succses")
                else
                    term.write(dep2)
                    pullapi.withdraw(dep)
                end
            end
        end
    elseif screen == 4 then
        if butt == 100 then
            traMode = false
            pinMode = false
            drawScreen(1)
        end
        if (withMode) then
            isWith, with = pinClick(butt, "Amm: ")
            if (isWith) then
                withMode = false
                if (tonumber(with) > 576) then
                    api.clear(backColor, true)
                    term.setCursorPos(17, 9)
                    term.write("Amount must be at maximum 576")
                else
                    api.clear(backColor, true)
                    term.setCursorPos(17, 5)
                    term.write("Please enter your pin")
                    term.setCursorPos(21, 8)
                    term.setBackgroundColor(backColor)
                    term.setTextColor(colors.lightGray)
                    pinMode = true
                    term.write("Pin: ")
                    pad = ""
                end
            end
        elseif (pinMode) then
            local isWPin, WPin = pinClick(butt, "Pin: ")
            if (isWPin) then
                pinMode = false
                api.clear(backColor, false)
                term.setCursorPos(17, 9)
                term.write("Withdrawing $")
                term.write(with)
                term.write(" from you account..")
                local isWith, with2 = api.withdraw(acc, with, atm, WPin)
                api.clear(backColor, true)
                term.setCursorPos(17, 9)
                if (isWith) then
                    term.write("succses")
                    pullapi.withdraw(tonumber(with))
                else
                    term.write(with2)
                end
            end
        end
    elseif screen == 5 then
        if butt == 100 then
            trasMode= false
            pinMode = false
            drawScreen(1)
        end
        if (trasMode) then
            isTras, tras = pinClick(butt, "Amm: ")
            if (isTras) then
                trasMode = false
                if (tonumber(tras) > 576) then
                    api.clear(backColor, true)
                    term.setCursorPos(17, 9)
                    term.write("Amount must be at maximum 576")
                else
                    api.clear(backColor, true)
                    term.setCursorPos(17, 5)
                    term.write("Please enter your pin")
                    term.setCursorPos(21, 8)
                    term.setBackgroundColor(backColor)
                    term.setTextColor(colors.lightGray)
                    pinMode = true
                    term.write("Pin: ")
                    pad = ""
                end
            end
        elseif (pinMode) then
            local isTPin, TPin = pinClick(butt, "Pin: ")
            if (isTPin) then
                pinMode = false
                api.clear(backColor, false)
                term.setCursorPos(17, 9)
                term.write("Transfering $")
                term.write(tras)
                term.write(" from you account..")
                local isTras, tras2 = api.transfer(acc, 1, tras, atm, TPin)
                api.clear(backColor, true)
                term.setCursorPos(17, 9)
                if (isTras) then
                    term.write("succses")
                else
                    term.write(tras2)
                end
            end
        end
    elseif screen == 6 then
        if butt == 999 then
            drawScreen(0)
            disk.eject(drive)
        end
    end
end

--Functions


--MainCode--

--SetupCode--
os.pullEvent = os.pullEventRaw
os.loadAPI("atm/api.lua")
os.loadAPI("atm/pullapi.lua")
drawScreen(0)

--SetupCode--

--MainLoop--
while true do
    event = {os.pullEvent()}
    if (event[1] == "terminate") then
        if (redstone.getInput("right")) then
            return
        end
    elseif (event[1] == "disk") then
        if (redstone.getInput("left")) then
            api.clear(backColor, false)
            term.setCursorPos(5, 5)
            term.write("Please enter pin: ")
            local txt = read("*")
            if txt == "pass" then
                drawScreen(6)
            else
                drawScreen(0)
                disk.eject(drive)
            end
        else
            acc = disk.getID(drive)
            if acc ~= nil then
                drawScreen(1)
            end
        end
    elseif (event[1] == "disk_eject") then
        if (escs) then
            pullapi.withdraw(dep)
        end
        drawScreen(0)
    elseif (event[1] == "mouse_click") then
        local click, but = onClick(event[3], event[4], 99)
        if (click) then
            prosClick(but)
        end
    elseif (event[1] == "char" or event[1] == "key") then
        local click, but = onClick(0, 0, event[2])
        if (click) then
            prosClick(but)
        end
    end
end
--MainLoop--

--MainCode--