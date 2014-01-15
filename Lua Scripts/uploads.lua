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

-------------------- TABLE FUNCTIONS END--------------------------------


-------------------DATE FuNCTIONS -----------

function datetotime(dat)	---- Converts date to time ( in a specif format only )
	d =  string.sub(dat,1,2)
	m =  string.sub(dat,4,5)
	y =  string.sub(dat,7,10)
	ftime = os.time{year = y,month = m,day = d}
	return ftime
end

function max_date(date_tbl)  ------ Finds out maximum date in a given table 
	max = 0
	for _,dt in pairs(date_tbl) do
		tm = datetotime(dt)
		if tm>= max then
			max = tm	
		end
	end
	return os.date("%d %m %Y",max)
end

function get_dates(cat) ------Catches last upload dates in given files 
	local today = os.time{year = os.date("%Y"),month =os.date("%m") ,day = os.date("%d")}
	local sof = assert(table_load('uploads\\'..cat..'.txt'))
	if sof == {} then 
		return {}
	end
	dttbl = {}
	for i,v in pairs(sof) do
		table.insert(dttbl,i)	
	end	
	fi_tbl = {}
	table.sort(dttbl, function(a,b) return datetotime(a)>datetotime(b) end)
	mx_dt = dttbl[1]	
	return dttbl
end

-------------  MAGNET LINK FUNCTIONS  -------------

function gethash(link)   ----- Gets the hash in a given magnet link
	x = link:find("xt=urn:tree:tiger:",1,true)
	y = link:find("xt=urn:bitprint:",1,true)
	if x~= nil then
		start = x+18
	else 
		start = y+16
	end
	--print(start)
	en = link:find("&",start,true)-1
	return link:sub(start,en)
end
function checkmagnet(ma) ---- checks if a given string is a given link is a magnet or not
	if ma == nil then 
		return false
	end
	if ma:find("magnet:?",1,true) and (ma:find("xt=urn:tree:tiger:",1,true) or ma:find("xt=urn:bitprint:",1,true)) and ma:find("xl=",1,true) and ma:find("dn=",1,true) then
		return true
	else 
		return false
	end
end
------------------------OLD FUNCTIONS END-----------------


---------------------- MISC functions -----------------
function string.split(st,sep)  ---------- Splits a given string and returns the table
	local sep,fields = sep or ":",{}
	local pattern = string.format("([^%s]+)",sep)
	st:gsub(pattern,function(c) fields[#fields + 1] = c end)
	return fields
	
end

function gen_path(category)
	path = 'uploads\\'..category..'.txt'
	return path
end

function arg_check_cat(argx,cat_list)
	for _,cats in pairs(cat_list) do		
		if argx:lower() == cats then			
			return cats,true
		end	
	end
	return nil
end

function generate_uploads(cat_list)
	local date_table = {}
	local upload_table = {}
	local temp2 = {}
	local temp1 = {}
	for _,cats in pairs(cat_list) do
		table.insert(date_table,get_dates(cats)[1])
	end
	
	table.sort(date_table, function(a,b) return datetotime(a)>datetotime(b) end)
	local max_date = date_table[1]
	if max_date == nil then
		return upload_table
	end
	date_table = {}
	for i = 0,2 do
		local x =  os.date("%d %m %Y",datetotime(max_date)-(2-i)*24*60*60)
		table.insert(date_table,x)
	end
	for _,dates in pairs(date_table) do
		for _,cats in pairs(cat_list) do
			temp1 = get_magnets(cats,dates)
			if upload_table[cats] ~= nil then
				temp2 = upload_table[cats]
				
			else
				temp2 = {}
			end
			for k,v in pairs(temp1) do temp2[k] = v end
			upload_table[cats] = temp2
		end
	end
	return upload_table	
end

function check_uploads(link,up_table)
	for i,v in pairs(up_table) do
		for x,magnets in pairs(v) do
			if gethash(link) == gethash(string.split(magnets,'||')[1])  then
				return i,string.split(magnets,'||')[2],true
				
			end
		end
	end
end

function get_magnets(cat,daet)
	local magnets_table = assert(table_load(gen_path(cat)))
	if magnets_table[daet] ~= nil then 
		return magnets_table[daet]
	else
		return {}
	end
end

function remove_magnet(cat,magnet,usr)
	local magnets_table = assert(table_load(gen_path(cat)))
	
	local x = false
	for dates, mags in pairs(magnets_table) do
		for index,mag in pairs(mags) do
			if magnet == string.split(mag,'||')[1] then
				table.remove(mags,index)
				x = true
			end
		end
	end
	table_save(magnets_table,gen_path(cat))
	return x
end

function add_magnet(cat,magnet,nick,tdate)
	local uploads_table = assert(table_load(gen_path(cat)))
	if uploads_table[tdate] ~= nil then
		table.insert(uploads_table[tdate],magnet..'||'..nick)
	else 
		uploads_table[tdate] = {}
		table.insert(uploads_table[tdate],magnet..'||'..nick)
	end
	table_save(uploads_table,gen_path(cat))
	
end
---------------- HUB Functions -----------
Tab = {Bot = "[Uploader-Bot]",	
	BotReg = true,	
	BotDesc = "Manages the uploads",	
	BotMail = "",	
	BotKey = true,
	OpNick = "Vestor",}
categories = {'games','sof','movies','series','others','videos'}
function OnStartup()
TmrMan.AddTimer(21000,"reset_limits")
today = os.time{year = os.date("%Y"),month = os.date("%m"),day = os.date("%d")}
Core.RegBot(Tab.Bot,Tab.BotDesc,Tab.BotMail,Tab.BotKey)
end
function reset_limits(id)
	
	if os.time{year = os.date("%Y"),month = os.date("%m"), day = os.date("%d")} - today >= (24*60*60) then
		local user_table = assert(table_load(gen_path("users")))
		user_table = {}
		table_save(user_table,gen_path("users"))
		Core.SendToNick(Tab.OpNick,"Okay the upload limits have been reset")
		today = os.time{year = os.date("%Y"),month = os.date("%m"), day = os.date("%d")}
	end
	return id
end

function ChatArrival(user,data)
	local _,_,msg = data:find( "%b<> (%S+)")
	local _,_,cmd = data:find( "^%b<> (%p%a+)")
	local _,_,arg = data:find( "^%b<> %p%a+ (%S+)")
	local _,_,arg2 = data:find( "^%b<> %p%a+ %S+ (.+)|")
	local _,_,argx = data:find("^%b<> %p%a+ (.+)|")
	if not cmd and checkmagnet(msg) then 
		Core.SendToUser(user,"<"..Tab.Bot.."> Hey "..user.sNick.." would you mind using the +upload or +u command to upload your file directly to the uploads section ? Thanks ! :D \n")
		return 
	end
	if cmd == "+u" or cmd == "+upload" then
		if not argx or argx:lower() == "help" then
			t = io.open(gen_path("help"))
			text = t:read("*all")
			text = text:gsub("<user>",user.sNick)
			Core.SendToNick(user.sNick,text)
		elseif  argx and argx:lower() == "about" then
			t2 = io.open(gen_path("about"))
			text2 = t2:read("*all")
			text2 = text2:gsub("<user>",user.sNick)
			Core.SendToNick(user.sNick,text2)
		elseif arg and arg_check_cat(arg,categories) then			
			local no_of_uploads = 0
			local limit = 0
			local cat
			local found
			local upload_user
			if user.iProfile == 4 or user.iProfile == 0 or user.iProfile == 1 then 
				limit = 25
			else 
				limit = 10
			end
			
			local magnet_tbl = string.split(arg2,"\n\r")
			for i,magnet in pairs(magnet_tbl) do
				if not checkmagnet(magnet) then
					table.remove(magnet_tbl,i)
					Core.SendToNick(user.sNick,"<"..Tab.Bot.."> Sorry user magnet link ( "..i.." ) is not appropriate")
				else
					Core.SendToNick(user.sNick,"<"..Tab.Bot.."> Magnet link "..i.." seem okay")
				end				
			end
			local category = arg_check_cat(arg,categories)
			local upload_table = generate_uploads(categories)
						
			local user_table = assert(table_load(gen_path("users")))
			if user_table[user.sNick] ~= nil then
				no_of_uploads = user_table[user.sNick]
				
			else 
				no_of_uploads = 0
			end
			today_date = os.date("%d").." "..os.date("%m").." "..os.date("%Y")
			for i, magnet in pairs(magnet_tbl) do
				cat,upload_user,found = check_uploads(magnet,upload_table)
				if found and upload_user then
					if upload_user == user.sNick then
						remove_magnet(cat,magnet,upload_user)
						add_magnet(category,magnet,user.sNick,today_date)
						Core.SendToNick(user.sNick,"<"..Tab.Bot.."> Updated "..magnet.." from [ "..cat.." ] to [ "..category.." ]")						
					else
						Core.SendToNick(user.sNick,"<"..Tab.Bot.."> Oops someone else uploaded [ "..magnet.." ] you cannont change it")
					end
				elseif not found then
					if no_of_uploads < limit then
						add_magnet(category,magnet,user.sNick,today_date)						
						no_of_uploads = no_of_uploads + 1
						Core.SendToNick(user.sNick,"<"..Tab.Bot.."> Okay your magnet [ "..magnet.." ] has been added to [ "..category.." ] in uploads")
						Core.SendToAll("<"..Tab.Bot.."> "..user.sNick.." uploaded [ "..magnet.." ]  to [ "..category.." ] in uploads")
						local chat_history = table_load('history.txt')
						local chat_line = "\n["..os.date("%H")..":"..os.date("%M")..":"..os.date("%S").."] <"..Tab.Bot.."> "..user.sNick.." uploaded [ "..magnet.." ]  to [ "..category.." ] in uploads"
						if table.getn(chat_history) >= 373 then 
							table.remove(chat_history,1)
							table.insert(chat_history,chat_line)			
						elseif table.getn(chat_history) >= 0 then
							table.insert(chat_history,chat_line)		
						end
						table_save(chat_history,'history.txt')
					else
						Core.SendToNick(user.sNick,"<"..Tab.Bot.."> Oh "..user.sNick..", you have reached your daily upload limit user.. sorry")
						break
					end
				end
			end
			Core.SendToNick(user.sNick,"<"..Tab.Bot.."> "..user.sNick..", you can upload ["..(limit-no_of_uploads).."] more links today.")
			user_table[user.sNick] = no_of_uploads
			table_save(user_table,gen_path("users"))			
			return true
		elseif arg == "rem" then
			local magnet_tbl = string.split(arg2,"\n\r")
			local user_table = assert(table_load(gen_path("users")))
			local no_of_uploads = 0
			if user_table[user.sNick] ~= nil then
				no_of_uploads = user_table[user.sNick]
			end
			local upload_table = generate_uploads(categories)
			for i,magnet in pairs(magnet_tbl) do
				cat,upload_user,found = check_uploads(magnet,upload_table)
				if found and upload_user then
					if upload_user==user.sNick or user.iProfile == 0 then
						remove_magnet(cat,magnet,upload_user)
						no_of_uploads = no_of_uploads - 1
						Core.SendToNick(user.sNick,"<"..Tab.Bot.."> ".."Okay, I have removed the link ["..magnet.."] from uploads")
					else
						Core.SendToNick(user.sNick,"<"..Tab.Bot.."> "..user.sNick..", you are not authorised to remove that, someone else uploaded it")
					end
				else 
					Core.SendToNick(user.sNick,"<"..Tab.Bot.."> ".."Sorry, I couldn't find the link in uploads section")
				end
			end
			user_table[user.sNick] = no_of_uploads
			table_save(user_table,gen_path("users"))
		else
			Core.SendToNick(user.sNick,"<"..Tab.Bot.."> ".."Hey "..user.sNick..", I can only offer these categories ["..table.concat(categories," , ").."]. Use one of them")
		end
		return true		
	elseif cmd and cmd == "+uploads" then 
		local date_table = {}
		local upload_table = {}
		local temp2 = {}
		local temp1 = {}
		for _,cats in pairs(categories) do
			table.insert(date_table,get_dates(cats)[1])
		end
		
		table.sort(date_table, function(a,b) return datetotime(a)>datetotime(b) end)
		local max_date = date_table[1]
		if max_date == nil then
			return upload_table
		end
		date_table = {}
		for i = 0,2 do
			local x =  os.date("%d %m %Y",datetotime(max_date)-(2-i)*24*60*60)
			table.insert(date_table,x)
		end		
		local message = ""
		for _,dt in pairs(date_table) do
			message = message.."\n+=+=+=+=+=+=+=+=+=     Uploads on "..dt.."     =+=+=+=+=+=+=+=+=+=+=+= \n"	
			for _,cats in pairs(categories) do				
				temp1 = table_load(gen_path(cats))
				if temp1[dt] ~= nil and table.getn(temp1[dt])>0 then
					if cats == "sof" then
						message = message.."\n\t\t--------------<<<<<".."SOFTWARES"..">>>>>--------------\r\n"
					else 
						message = message.."\n\t\t--------------<<<<<"..cats:upper()..">>>>>--------------\r\n"
					end
					for count,magnets in pairs(temp1[dt]) do
						message = message.." "..count..") "..string.split(magnets,'||')[1].."  by "..string.split(magnets,'||')[2].."\n"
					end
				end
			end
		end
		message = message.."\n Uploads are updated in realtime ; Downloaders please use +upload or +u command to add to uploads list\n ANd the upload command has been updated so use +upload or +u help		"
		Core.SendToNick(user.sNick,"\n"..message)
		--return true
	end
end