local enet = require("enet")

local host = enet.host_create()
local ck = false
server = nil

local serverIP = "26.174.80.45"
local enteringIP = false

local idd = false

local username = ""

local dd = false

local isConnected = false

local otherPlayers = {}

local walk = love.audio.newSource("audio/walk.mp3", "static")
local bgmusic = love.audio.newSource("audio/music.mp3", "stream")

local px = 150
local py = 150

local pspeed = 300

local musicon = true

function love.load()

    love.window.setMode(800, 600, {resizable = false})
    love.window.setTitle("Rockworks test client")

    cimg = love.graphics.newImage("images/Rat.png")

    spon = love.graphics.newImage("images/spon.png")
    spoff = love.graphics.newImage("images/spoff.png")

    lfont = love.graphics.newFont(19)
    nfont = love.graphics.newFont(12)
    dfont = love.graphics.newFont(15)
    hfont = love.graphics.newFont(14)

    if musicon then

    bgmusic:play()
    bgmusic:setVolume(0.2)

    end

end

function love.textinput(text)
    if enteringIP then
        serverIP = serverIP .. text
    elseif not dd then  
        username = username .. text
    end
end

function love.keypressed(key)
    if key == "backspace" then
        if enteringIP then
            serverIP = serverIP:sub(1, -2)
        elseif not dd then
            username = username:sub(1, -2)
        end
    elseif key == "return" then
        if enteringIP then
            enteringIP = false
            idd = true
        else
            dd = true
        end
    elseif key == "c" and dd then
        ck = true
        server = host:connect(serverIP .. ":12345")
    elseif not idd and key == "i" and dd then
        enteringIP = true
        serverIP = ""
    end
end

function love.mousepressed(x, y, button, istouch)

    if button == 1 and x >= 600 and x <= 800 and y >= 0 and y <= 200 then

        musicon = not musicon

        if musicon then

            bgmusic:play()

        else

            bgmusic:stop()

        end

    end

end

function love.update(dt)

    if ck then  

    local event = host:service()

    while event do

        if event.type == "connect" then

            isConnected = true

        elseif event.type == "receive" then

            otherPlayers = {}

             for playerData in event.data:gmatch("([^;]+);") do

             local uname, x, y = playerData:match("([^,]+),(-?%d+%.?%d*),(-?%d+%.?%d*)")
             x, y = tonumber(x), tonumber(y)

             if uname and x and y then

             otherPlayers[uname] = { x = x, y = y }

               end

            end

        elseif event.type == "disconnect" then

            isConnected = false

            otherPlayers = {}

        end 

        event = host:service()

    end

    if server and server:state() ~= "connected" then

        isConnected = false

    end

    if isConnected then

        local moved = false

    if love.keyboard.isDown("w") then

        py = py-pspeed * dt

        moved = true

    end

    if love.keyboard.isDown("s") then 

        py = py+pspeed * dt

        moved = true

    end

    if love.keyboard.isDown("a") then 

        px = px-pspeed * dt

        moved = true

    end

    if love.keyboard.isDown("d") then 

        px = px+pspeed * dt

        moved = true 

    end

    if moved then

        if not walk:isPlaying() then

            walk:play() end end


            if moved and isConnected then

                local data = username .. "," .. px .. "," .. py

                server:send(data)

            end


    if musicon and not bgmusic:isPlaying() then

        bgmusic:play()
        
    end

    end

    end

end

function love.draw()

    if isConnected then
        
        love.graphics.setFont(hfont)
        love.graphics.print("Connected to Server!", 10, 10)

    else

        if not ck then 

        love.graphics.setFont(lfont)
        love.graphics.print("Connect to the Server to play. Press C to connect", 165, 350) end

        love.graphics.setFont(lfont)
        if not dd then love.graphics.print("Write your username before connecting. Press ENTER to confirm.", 93, 300) end

        love.graphics.setFont(lfont)
        if not ck and not idd and dd then love.graphics.print("Press i to enter IP. PORT IS FIXED. Top left corner (Not Mandatory).", 92, 400) end

        love.graphics.setFont(hfont)
        love.graphics.print("Connecting to Server...", 10, 10)

    end

    love.graphics.setFont(nfont)
    love.graphics.print("Server IP: " .. serverIP, 10, 30)

    love.graphics.setFont(nfont)
    love.graphics.print("POS X:" .. px, 10, 70)
    love.graphics.setFont(nfont)
    love.graphics.print("POS Y:" .. py, 10, 90)

    love.graphics.setFont(hfont)
    love.graphics.print(username, px + 37, py)
    love.graphics.draw(cimg, px, py, 0, 0.1, 0.1)

   if musicon then
    
    love.graphics.setFont(nfont)
    love.graphics.draw(spon, 690, 10, 0, 0.1, 0.1)

   elseif not musicon then 
    
    love.graphics.setFont(nfont)
    love.graphics.draw(spoff, 665, 10, 0, 0.25, 0.25)

   end

   love.graphics.setFont(dfont)
   love.graphics.print("This is an alpha version of Rockworks, intended for testing only and not to be sold or distributed.", 10, 580)

    love.graphics.setFont(lfont)
   love.graphics.print("Use WASD to move.", 300, 10)


   for uname, pos in pairs(otherPlayers) do

    love.graphics.setFont(nfont)
    love.graphics.print(uname, pos.x + 37, pos.y - 10)
    love.graphics.draw(cimg, pos.x, pos.y, 0, 0.1, 0.1)

   end

end
