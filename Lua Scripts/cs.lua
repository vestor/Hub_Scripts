local bot = function() 
			if Core then 
				return SetMan.GetString(21) 
			else
				return frmHub:GetHubBotName() 
			end 
			end
			

OpNick = "Vestor"
function OnStartup()
	Core.SendToNick(OpNick,"CS Script Started")
	end
function ChatArrival(user,data)
	bot = "[Joker]"
		
	local _,_,msg = data:find( "%b<> (.+)")
	local _,_,cmd = data:find( "^%b<> (%p%a+)")
	local _,_,arg = data:find( "^%b<> %p%a+ (%S+)|")
	
	if cmd and cmd == "!cs" or cmd=="+cs" then
		local cs = "CS.txt"
		local f = io.open(cs, "r")
		local	t2 = f:read("*all")
		Core.SendToUser(user,"<"..bot.."> "..t2 )
	end
end
	

