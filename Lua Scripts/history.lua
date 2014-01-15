local function exportstring( s )
      return string.format("%q", s)
   end
function table_load( sfile )
      local ftables,err = loadfile( sfile )
      if err then return _,err end
      local tables = ftables()
      for idx = 1,#tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         -- link indices
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
   end
function table_save(  tbl,filename )
      local charS,charE = "   ","\n"
      local file,err = io.open( filename, "wb" )
      if err then return err end

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }
      file:write( "return {"..charE )

      for idx,t in ipairs( tables ) do
         file:write( "-- Table: {"..idx.."}"..charE )
         file:write( "{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then
            
               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end
            
               if str ~= "" then
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write( "},"..charE )
      end
      file:write( "}" )
      file:close()
   end
   
   
 ---------------TABLE FUNCTIONS END ----------  
Tab = {Bot = "[History-Bot]",	
	BotReg = true,	
	BotDesc = "I look out for the history",	
	BotMail = "",	
	BotKey = true,
	OpNick = "Vestor",}
	
function OnStartup()
Core.RegBot(Tab.Bot,Tab.BotDesc,Tab.BotMail,Tab.BotKey)
end

function UserConnected(user,data)
	local chat_history = table_load('history.txt')
	local final = ""
	local en = table.getn(chat_history)
	for i,v in pairs(chat_history) do
		--if en - i > 30 then
		--	break
		--end
		if en - i <= 19 then
			final = final..v
		end
	end
	y = ""
	y = y.."\n =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"	
	y= y.."\n The UPLOAD command has been updated , downloaders please use +upload help or +u help for more info."
	y = y.."\n =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
	Core.SendToNick(user.sNick,"<"..Tab.Bot.."> "..final.."\n | Here are last 20 lines in Main Chat, use +history <no. of lines> for more"..y)
end
OpConnected = UserConnected
function ChatArrival(user,data)
	local _,_,cmd = data:find( "^%b<> (%p%a+)")
	local _,_,arg = data:find( "^%b<> %p%a+ (%d+)")
	local _,_,msg = data:find("^%b<> (.+)|")	
	
			
	if not cmd then		
		chat_history = table_load('history.txt')
		Core.SendToNick(Tab.OpNick,"< > "..table.getn(chat_history))
		local chat_line = "\n["..os.date("%H")..":"..os.date("%M")..":"..os.date("%S").."] <"..user.sNick.."> "..msg		
		if table.getn(chat_history) >= 373 then 
			table.remove(chat_history,1)
			table.insert(chat_history,chat_line)
			
		elseif table.getn(chat_history) >= 0 then
			table.insert(chat_history,chat_line)
			
		end
		table_save(chat_history,'history.txt')
		chat_history = {}
	elseif cmd and cmd == "+history" then
		chat_history = table_load('history.txt')
		if not arg then
			local final = ""
			local en = table.getn(chat_history)
			for i,v in pairs(chat_history) do
				--if en - i > 30 then
				--	break
				--end
				if en - i <= 29 then
					final = final..v
				end
			end
			Core.SendToNick(user.sNick,"<"..Tab.Bot.."> "..final)
		elseif arg == "help" then 
			Core.SendToNick(user.sNick,"<"..Tab.Bot.."> ".." Just use +history of +history <number-of-lines>")
		elseif type(tonumber(arg)) == "number" and tonumber(arg) <= 373 then
			local final = ""
			local en = table.getn(chat_history)
			local n = table.getn(chat_history)
			for i,v in pairs(chat_history) do 
				--if en - i > tonumber(arg) then 
				--	break
				--end 
				if en - i <= tonumber(arg) - 1 then
				final = final..v
				end
			end
			Core.SendToNick(user.sNick,"<"..Tab.Bot.."> "..final.." ")		
		
		end
		return true	
	end
	chat_history = {}
end	
	