local bot = function() 
			if Core then 
				return SetMan.GetString(21) 
			else
				return frmHub:GetHubBotName() 
			end 
	end
			
Tab = {Bot = "[Joker]",	
	BotReg = true,	
	BotDesc = "meh",	
	BotMail = "",	
	BotKey = true,
	OpNick = "Vestor",}

function OnStartup()
	Core.SendToNick(Tab.OpNick,"HUBS Script Started")
	end
function ChatArrival(user,data)	
		
	local _,_,msg = data:find( "%b<> (.+)")
	local _,_,cmd = data:find( "^%b<> (%p%a+)")
	local _,_,arg = data:find( "^%b<> %p%a+ (%S+)|")
	
	if cmd and cmd == "!hublist" or cmd=="+hublist" then
		local hubs = "hubs2.txt"
		local f = io.open(hubs, "r")
		local	t2 = f:read("*all")
		Core.SendToUser(user,"<"..Tab.Bot.."> "..t2 )
		f:close()
	end
	
	
end
