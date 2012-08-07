--[[

This is a lua-script to show some useful informations about blocks in Super Mario World.
It shows the frame when you have to throw an item, to duplicate the chosen block in which direction
(So it has to show "LEFT" if you want to duplicate to the left) or you can choose a line where you wanna duplicate.
It also shows when you can Walljump or Cornerclip.

Leftclick: Show/Hide the selection with informations
Rightclick: Toggle betweeen a box and a line around your mouse

Script by Masterjun

]]--

local left = true --touching block from left
local right = true --touching block from right
local bottom = true --for duplicating
local walljump = true --walljump help
local cornerclip = true --cornerclip help

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
	local xspeed = memory.readbytesigned(0x7E007B)
	local input=input.get()
	
	local lastxcam
	if xcamc then
		lastxcam=xcamc
	else
		lastxcam=memory.readword(0x7E001A)
	end
	local lastycam
	if ycamc then
		lastycam=ycamc
	else
		lastycam=memory.readword(0x7E001A)
	end
	
	local xcam=memory.readword(0x7E001A)
	xcamc=memory.readword(0x7E001A)
	local ycam=memory.readword(0x7E001C)
	ycamc=memory.readword(0x7E001C)
	local x1=input.xmouse-(xcam+input.xmouse)%16
	local y1=input.ymouse-((ycam+input.ymouse)+1)%16
	local x2=x1+15
	local y2=y1+15
	local nearblock=false
	local xoffset=lastxcam-xcam
	local yoffset=lastycam-ycam
	
	if Press("rightclick") then
		if showbox then
			showbox=false
		else
			showbox=true
		end
	end
	
	gui.transparency(2)
	if showbox then gui.box(x1-xoffset,y1-yoffset,x2-xoffset,y2-yoffset,"#FFFFFF") 
	else
		if not y1line then
			gui.line(0,y1-yoffset,256,y1-yoffset)
			gui.line(0,y2-yoffset,256,y2-yoffset)
		end
	end
	
	--This is a grid for the boxes
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
		if showbox then
			if not x1box then
				x1box=x1
				y1box=y1
				x2box=x2
				y2box=y2
				xcambox=xcam
				ycambox=ycam
			elseif x1box-xdiff==x1 and y1box-ydiff==y1 then x1box=nil
			else
				x1box=x1
				y1box=y1
				x2box=x2
				y2box=y2
				xcambox=xcam
				ycambox=ycam
			end
		else
			if not y1line then
				y1line=y1
				y2line=y2
				ycambox=ycam
			elseif y1line==y1 then y1line=nil
			else
				y1line=y1
				y2line=y2	
				ycambox=ycam
			end
		end
	end

	if showbox==true then
		y1line=nil
	else
		x1box=nil
	end
	
	if y1line then
		ydiff=ycam-ycambox
		gui.line(0,y1line-ydiff-yoffset,256,y1line-ydiff-yoffset)
		gui.line(0,y2line-ydiff-yoffset,256,y2line-ydiff-yoffset)
		gui.transparency(0)
		if bottom then gui.text(8,y2line-ydiff+1,y1line+ycambox+15) end
	end
	
	if x1box then
		xdiff=xcam-xcambox
		ydiff=ycam-ycambox
		gui.box(x1box-xdiff-xoffset,y1box-ydiff-yoffset,x2box-xdiff-xoffset,y2box-ydiff-yoffset,"#FFFFFF")
		gui.transparency(0)
		--The three values for the box
		if bottom then gui.text(x2box-xdiff-13-xoffset,y2box-ydiff+1-yoffset,y1box+ycambox+15) end
		if right then gui.text(x2box-xdiff+2-xoffset,y2box-ydiff-13-yoffset,x1box+xcambox+13) end
		if left then gui.text(x1box-xdiff-16-xoffset,y2box-ydiff-13-yoffset,x1box+xcambox-14) end
	end
	
	--Duplication help
	if slot then
		local yposh=memory.readbyte(0x7E14D4+slot)
		local xposh=memory.readbyte(0x7E14E0+slot)
		local yposl=memory.readbyte(0x7E00D8+slot)
		local xposl=memory.readbyte(0x7E00E4+slot)
		local ysubpos=memory.readbyte(0x7E14EC+slot)
		local guiypos=58
		local ypositem=yposl+yposh*256
		local xpositem=xposl+xposh*256
		local all=(ypositem)*16+ysubpos/16
		
		if y1line then nearblock=true
		elseif x1box and xpositem <= x1box+xcambox+7 and xpositem >= x1box+xcambox+4 then nearblock=true
		elseif x1box and xpositem >= x1box+xcambox-8 and xpositem <= x1box+xcambox-5 then nearblock=true
		else nearblock=false
		end
		
		if (bottom and x1box) or (bottom and y1line) then
			local blockbottom=y1box+ycambox+15
			gui.text(210,50,string.format("%d.%02x",ypositem, ysubpos))
			j=nil
			for i = 0,15,3 do
				all=all-(112-i)
				if y1box and (all-all%16)/16 == (blockbottom) then
					j=i
				end
				--if y1box then gui.text(100,guiypos+42,string.format("%d %d",(all-all%16)/16,(blockbottom)+1)) end
				if j==i-3 and (all-all%16)/16 == (blockbottom)-7 and nearblock then
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
			
			if ypositem > (blockbottom)-8 and ypositem < (blockbottom)+1 and nearblock then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
				
			if ypositem == (blockbottom)-8 and nearblock then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
				
			if ypositem == (blockbottom)-9 and nearblock then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
				
			if ypositem == (blockbottom)-8 and nearblock then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
				
			if ypositem == (blockbottom)-9 and nearblock then
				if memory.readbyte(0x7E0013)%2==0 then
					gui.text(236,50,"LEFT","#FF0000")
				else
					gui.text(236,50,"RIGHT","#FF0000")
				end
			end
				
			if ypositem == (blockbottom)-8 or ypositem == (blockbottom)-9 and nearblock then
				gui.text(236,42,"TOP","#FF0000")
			end
		end
	end
	if x1box then
		local xspeed = memory.readbytesigned(0x7E007B)
		local xsubspeed = memory.readbyte(0x7E007A)
		local xpos = memory.readword(0x7E0094)
		local xsubpos = memory.readbyte(0x7E13DA)
		local allpos = xpos*16 + xsubpos/16
		local r = (x1box+xcambox+13)*16
		local l = (x1box+xcambox-14)*16
		if walljump or cornerclip then	
		gui.text(28,38,xspeed)
			if xspeed>32 and xpos-8<l/16 then
				local calpos=allpos
				while calpos<l do
					calpos=calpos+xspeed
				end
				calpos=calpos-xspeed*2
				for i = 0,4 do
					local tpos=calpos+i*xspeed
					if tpos-15 <= l then
						j=i
					end
					if tpos-15 <= l+32 then
						k=i
					end
					if k==i-1 and tpos-15 >= l+81 and cornerclip then
						gui.text(8,i*8+50,"CC","#FF0000")
					end
					if j==i-1 and tpos-15 >= l+33 and walljump then
						gui.text(8,i*8+50,"WJ","#FF0000")
					end
					gui.text(24,i*8+50,string.format("%d.%02x",(tpos-tpos%16)/16,(tpos%16)*16))		
				end
			end

			if xspeed<(-32) and xpos+8>r/16 then
				local calpos=allpos
				while calpos>r do
					calpos=calpos+xspeed
				end
				calpos=calpos+xspeed
				for i = 0,4 do
					local tpos=calpos-(4-i)*xspeed
					if tpos >= r then
						j=i
					end
					if tpos >= r-32 then
						k=i
					end
					if k==i-1 and tpos <= r-81 and cornerclip then
						gui.text(8,i*8+50,"CC","#FF0000")
					elseif j==i-1 and tpos <= r-33 and walljump then
						gui.text(8,i*8+50,"WJ","#FF0000")
					end
					gui.text(24,i*8+50,string.format("%d.%02x",(tpos-tpos%16)/16,(tpos%16)*16))
				end
			end
		end
	end
end

gui.register(function()
carry()
main(slot)
end)