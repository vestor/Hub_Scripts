local bot = function() 
			if Core then 
				return SetMan.GetString(21) 
			else
				return frmHub:GetHubBotName() 
			end 
			end
			

OpNick = "Vestor"
function OnStartup()
	Core.SendToNick(OpNick,"COD Script Started")
	end
function ChatArrival(user,data)
	bot = "[Joker]"
		
	local _,_,msg = data:find( "%b<> (.+)")
	local _,_,cmd = data:find( "^%b<> (%p%a+)")
	local _,_,arg = data:find( "^%b<> %p%a+ (%S+)|")

	if cmd and cmd == "!cod" or cmd=="+cod" then
		local cod = "COD.txt"
		local f = io.open(cod, "r")
		local	t2 = f:read("*all")
		Core.SendToUser(user,"<"..bot.."> "..t2 )
	end
end
	
