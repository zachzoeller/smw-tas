--[[

This is a lua-script to show some useful informations about blocks in Super Mario World.
It shows the frame when you have to throw an item, to duplicate the chosen block in which direction.
(So it has to show "LEFT" if you want to duplicate to the left)

Leftclick: Show/Hide informations about the chosen block
Rightclick: Show/Hide the box around your mouse

Script by Masterjun

]]--

local left = true --touching block from left
local right = true --touching block from right
local bottom = true --for duplicating

---------------------------------------------------

--from smwutils.lua
local keys, lastkeys= input.get(), input.get()
local function UpdateKeys() lastkeys= keys;  keys= input.get() end
local function Press(k) return keys[k] and (not lastkeys[k]) end


local showbox = true

local x1box
local y1box
local x2box
local y2box	

--find out which item is in mario's hands (if doublegrab, then it will use the highest slot)
function carry()
	temp=nil
	for i = 0,11 do
		if memory.readbyte(0x7E14C8 + i) == 11 then
			temp=i
		end
	end
	slot=temp
	return slot
end

function main(slot)
	UpdateKeys()
	local input=input.get()
	local xcam=memory.readword(0x7E001A)
	local ycam=memory.readword(0x7E001C)
	
	local x1=input.xmouse-(xcam+input.xmouse)%16
	local y1=input.ymouse-(ycam+input.ymouse)%16-1
	
	local x2=x1+15
	local y2=y1+15
	
	if Press("rightclick") then
		if showbox then
			showbox=false
		else
			showbox=true
		end
	end
	
	
	
	gui.transparency(2)
	if showbox then gui.box(x1,y1,x2,y2,"#FFFFFF") end
	
	--This was a grid for the boxes
	--[[
	gui.transparency(2)
	for i=xcam%16,256,16 do
		gui.line(256-i,0,256-i,224)
		gui.line(255-i,0,255-i,224)
	end
	for i=ycam%16,224,16 do
		gui.line(0,223-i,256,223-i)
		gui.line(0,222-i,256,222-i)
	end
	gui.transparency(0)
	]]--
	

	
	if Press("leftclick") then
		if x1box==x1 and y1box==y1 then x1box=nil
		else 
			x1box=x1
			y1box=y1
			x2box=x2
			y2box=y2
			xcambox=xcam
			ycambox=ycam
		end
	end
	if x1box then
		xdiff=xcam-xcambox
		ydiff=ycam-ycambox
		gui.box(x1box-xdiff,y1box-ydiff,x2box-xdiff,y2box-ydiff,"#FFFFFF")
		gui.transparency(0)
		--The three values for the box
		if bottom then gui.text(x2box-xdiff-13,y2box-ydiff+1,y1box+ycambox+15) end
		if right then gui.text(x2box-xdiff+2,y2box-ydiff-13,x1box+xcambox+13) end
		if left then gui.text(x1box-xdiff-16,y2box-ydiff-13,x1box+xcambox-14) end
	end
	
	--Duplication help
	if slot then
		local yposh=memory.readbyte(0x7E14D4+slot)
		local xposh=memory.readbyte(0x7E14E0+slot)
		local yposl=memory.readbyte(0x7E00D8+slot)
		local xposl=memory.readbyte(0x7E00E4+slot)
		local ysubpos=memory.readbyte(0x7E14EC+slot)
		local guiypos=58
		local all=(yposl+yposh*256)*16+ysubpos/16
		
		if bottom and x1box then
			gui.text(210,50,string.format("%d.%02x",yposl+yposh*256, ysubpos))
			j=nil
			for i = 0,15,3 do
				all=all-(112-i)
				if y1box and (all-all%16)/16 == (y1box+ycambox+15) then
					j=i
				end
				--if y1box then gui.text(100,guiypos+42,string.format("%d %d",(all-all%16)/16,(y1box+ycambox+15)+1)) end
				if j==i-3 and (all-all%16)/16 == (y1box+ycambox+15)-7 then
					if (j/3)%2==0 then
						if memory.readbyte(0x7E0013)%2==1 then
							gui.text(236,guiypos,"LEFT","#FF0000")
						else
							gui.text(236,guiypos,"RIGHT","#FF0000")
						end
					else
						if memory.readbyte(0x7E0013)%2==0 then
							gui.text(236,guiypos,"LEFT","#FF0000")
						else
							gui.text(236,guiypos,"RIGHT","#FF0000")
						end
					end
				end
				
				gui.text(210,guiypos,string.format("%d.%02x",(all-all%16)/16,all%16*16))
				
				guiypos=guiypos+8
			end
			
			if yposl+yposh*256 > (y1box+ycambox+15)-8 and yposl+yposh*256 < (y1box+ycambox+15)+1 then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
			
			if yposl+yposh*256 == (y1box+ycambox+15)-8 and xposl+xposh*256 <= x1box+xcambox+7 and xposl+xposh*256 >= x1box+xcambox+4 then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
			if yposl+yposh*256 == (y1box+ycambox+15)-9 and xposl+xposh*256 <= x1box+xcambox+7 and xposl+xposh*256 >= x1box+xcambox+4 then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
			
			if yposl+yposh*256 == (y1box+ycambox+15)-8 and xposl+xposh*256 >= x1box+xcambox-8 and xposl+xposh*256 <= x1box+xcambox-5 then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
			if yposl+yposh*256 == (y1box+ycambox+15)-9 and xposl+xposh*256 >= x1box+xcambox-8 and xposl+xposh*256 <= x1box+xcambox-5 then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
			
			if yposl+yposh*256 == (y1box+ycambox+15)-8 or yposl+yposh*256 == (y1box+ycambox+15)-9 then
				gui.text(236,42,"TOP","#FF0000")
			end
			
			--X camera things
			
			--gui.text(100,100,string.format("%d, %d, %d..%d",xposl+xposh*256, x1box+xcambox-8, x1box+xcambox+7, (y1box+ycambox+15)-9 ))
		
		end
	end
end

gui.register(function()
carry()
main(slot)
end)