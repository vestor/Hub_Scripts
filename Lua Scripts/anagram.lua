count = 0
user_list = {}
OpNick = "Vestor"
function pad(s, width, padder)
  padder = strrep(padder or " ", abs(width))
  if width < 0 then return strsub(padder .. s, width) end
  return strsub(s .. padder, 1, width)
end
local bot = function() 
			if Core then 
				return SetMan.GetString(21) 
			else
				return frmHub:GetHubBotName() 
			end 
			end
gamestarted = true			
gamestarted = true			
function ChatArrival(user,data)
	local _,_,msg = data:find( "%b<> (.+)")
	local _,_,cmd = data:find( "^%b<> (%p%a+)")
	local _,_,arg = data:find( "^%b<> %p%a+ (%S+)|")
	
	local s,e,var1=data:find("%b<>%s+(%a+)") 	
	--if cmd and cmd == "+an" and arg == "about" then
	--	Core.SendToUser(user,"\n\n       Hey there "..user.sNick.." ! I hope that you like the Anagram game.\n\n This game was written in LUA for ptokaX hub software over a period of arnd 3 days\n\n If you find any kind of bugs please PM me; as I couldn't test it forever :P\n Everykind of suggestion or criticism is very much welcomed ! Please feel free. And yeah, \n\n Credits :\n --Coded by: Vestor (apart frm the list of words, it is hand coded :P ) \n -- Heavy Thanks to Fireboy and Vizard \n who helped me transform an ugly looking game to a presentable one and pointed out gazillion bugs  \nTHanks gUys ur awesome:D \n")
		
	--end
	
	--if cmd and cmd == "+an" and arg == "help" then
	--	local again = false
	--	for _,u in pairs(user_list) do 
	--		if u==user.sNick then
	--			again = true
	--			break
	--		end
	--	end
	--	if again == false then
	--		table.insert(user_list,user.sNick)
	--		Core.SendToUser(user,"\n\n       [The Riddler] "..user.sNick.." You were supposed to understand. I'll make you understand!\n                             So.. you can type :\n                         +an start for taking up my challenge  \n                         +an stop to give up \n                         +an showscores for my top ten wanted  \n                         +an myscore for your score \n \n                         +an about for something interesting \n   ")
			
	--	elseif again==true then
	--		Core.SendToUser(user,"\n\n       [The Riddler] "..user.sNick.." I thought I made it clear in the first time!\n                             So.. you can type :\n                         +an start for taking up my challenge  \n                         +an stop to give up \n                         +an showscores for my top ten wanted  \n                         +an about for something interesting \n")
	--		
	--	end
	--end
	if cmd and cmd == "+an" and arg == "start" then
		count= count +1
		times  = 0
		if count <2 then
			gamestarted = false
			indices = {}
			Core.SendToAll("<[The Riddler]> "..user.sNick.." started Riddler's Anagram Challenge\n")
			anagram()
			return true
		else 
			Core.SendToUser(user,"<[The Riddler]> A challenge is already underway "..user.sNick.."\n")
			return true
		end
	end
	if cmd and cmd == "+an" and arg == "showscores" then
	local score_table = assert(table_load("anagramscores.txt"))
	local curr_time = os.date("%I")..":"..os.date("%M").." "..os.date("%p").."   "..os.date("%A").." "..os.date("%x")
	
	local scores = "                              Nick                      Score\n" 
	scores =scores.."=============================================================\n" 
	local coun = 1
	scores=scores..pair_by_score(score_table)
	Core.SendToUser(user,"\n                             RIDDLER's MOST WANTED \n                                  In Gotham Central\n\n"..scores.."\n" )
	
	end
	if cmd and cmd == "+an" and arg == "myscore" then
		local curr_time = os.date("%I")..":"..os.date("%M").." "..os.date("%p").."   "..os.date("%A").." "..os.date("%x")
		local score_table = assert(table_load("anagramscores.txt"))
		local scores = "\n          Your Score as of "..curr_time.." is \n"
		scores = scores.."             "..user.sNick.."  ;  Score : "..score_table[user.sNick].."\n"
		Core.SendToUser(user,scores)
		
	end
	if cmd and cmd == "+an" and arg=="stop" then
	if gamestarted == false then
		
		Core.SendToAll("<[The Riddler]>  "..user.sNick.." forced you all to give up on Riddler's Anagram Challenge")
		whore =""
		if hid~=nil then
			TmrMan.RemoveTimer(idx)
		end
		if id2~=nil then
			TmrMan.RemoveTimer(id2)
		end
		gamestarted= true
		
	elseif gamestarted ==true then
		Core.SendToUser(user,"<[The Riddler]>  Hey "..user.sNick.." there is no running challenge !! wanna start one type +an start")
	end
		count = 0
		return true
	end
	
	
	if var1 then 
		if var1:upper() == whore then
			if idx ~= nil then
				TmrMan.RemoveTimer(idx)
			end
			if hid ~= nil then
				TmrMan.RemoveTimer(idx)
			end
			finished = true
			
			anagram_score = table_load("anagramscores.txt")
			if anagram_score == nil then 
				anagram_score = {}
			end
			if anagram_score[user.sNick] ~=nil then
				anagram_score[user.sNick] = anagram_score[user.sNick]+points
			else 
				anagram_score[user.sNick]=points
			end
			table_save(anagram_score,"anagramscores.txt")
			Core.SendToAll("<[The Riddler]> The Riddler rewards "..user.sNick.." with ["..points.."] points on guessing the right word ["..whore.."]\n")
			
			times = 0
			TmrMan.AddTimer(7000,"hoax")
			whore = ""
			return true
		end
		
	end
		
end
function hoax(Id)	
	id2 = Id
	TmrMan.RemoveTimer(Id)
	anagram()	
end
function good_view(nick,score)
	local le_ni = string.len(nick)
	local le_sc = string.len(score)
	local spaces = 80-(le_ni+le_sc)
	local sp = string.format("%"..spaces.."s"," ")
	local final = nick..sp..score
	return final
end
function anagram()
	if gamestarted == false then
		if hid~= nil then
			TmrMan.RemoveTimer(hid)
		end
		if id2~= nil then
			TmrMan.RemoveTimer(hid)
		end
		if times <=4 then 
		 
			whore =(pick_a_word("Words.txt",indices,20654)):upper()
			anw = ana_gen(whore)
			Core.SendToNick(OpNick,"  "..whore)
			an_w = ""
			local co
			for co =1,string.len(anw) do
				an_w = an_w..string.sub(anw,co,co).." "
			end
			hs = hints(whore)
			--table_save(hs,"C:\\0.4.1.2\\scripts\\test.txt")
			counter = 1
			
			Core.SendToAll("<[The Riddler]> Riddler's new riddle is    < "..an_w.." >")
			points = 25
			finished = false
			TmrMan.AddTimer(7000,"hints_display")
		elseif times > 4 then 
			Core.SendToAll("<[The Riddler]> The Riddler hysterically laughs at your ignorance and stops the anagram !")	
			count = 0
			times = 0
			if hid~= nil then
				TmrMan.RemoveTimer(hid)
			end
			if id2~= nil then
				TmrMan.RemoveTimer(hid)
			end
		end		
	end
end

function hints_display(Id)
		hid = Id
		if gamestarted == false then
			idx= Id
			if finished == false then
				if counter < 5 then
					--Core.SendToNick("Fireboy","<[The Riddler]>    Hint("..counter.."/4):                    [ "..hs[counter].." ]     ###   < "..an_w.." >")
					Core.SendToAll("<[The Riddler]>    Hint("..counter.."/4):                    [ "..hs[counter].." ]     ###   < "..an_w.." >")
					points = points - 5
				end
				counter = counter + 1
				if counter>5 then
					--Core.SendToNick("Fireboy","<[The Riddler]> You should take Batman's help to solve anagrams! The word was  ["..whore.."]")
					Core.SendToAll("<[The Riddler]> You should take Batman's help to solve anagrams! The word was  ["..whore.."]")
					whore = ""
					times = times + 1
				end
				if counter > 6 then
					TmrMan.RemoveTimer(hid)
					anagram()
					
				end
			end
		end
end
function OnTimer(Id)
	local an_w = ana_gen(whore)
	local hs = hints(whore)
	--Core.SendToNick("Fireboy","< >".." "..an_w.." ".."  "..hs[1].."  "..hs[2].."  "..hs[3].."  "..hs[4])		
	Core.SendToAll("< >".." "..an_w.." ".."  "..hs[1].."  "..hs[2].."  "..hs[3].."  "..hs[4])		
end

function pair_by_score(tbl)
	local score_list = ""
	local a = {}
	local final = {}
	local coun = 1
	for x,n in pairs(tbl) do table.insert(a,n) end
	table.sort(a,function(a,b) return b<a end)
	for x,n in pairs(a) do
			for i,j in pairs(tbl) do
				if j==n then
					final[coun] = i
					coun = coun +1
					break
				end
			end
	end
	
	
	for i=1,10 do
		local x = string.len(final[i])
		x = 20 - x
		local sp = ""
		for j=1,x/2 do
			sp = sp.." -"
		end
		score_list=score_list.."                              "..i..") "..final[i]..sp..tbl[final[i]].." \n"
		
	end
	return score_list
	
end
function pick_a_word(file,dx,sz)
	math.randomseed(os.time()+123456)
	local x
	local flag
	local i
	local u
	local word
	while true do
		x=math.random(sz-1)
		flag = false
		i=1
		while true do
			if dx~=nil and dx[i] ~= nil then 
				if x==dx[i]	then
					flag = true
				break
				end
			else break			
			end
			i=i+1
		end
		if flag == false then break end
	end
	dx[i] = x
	--print_x(dx)
	u = 1
	for line in io.lines(file) do 
		if x==u then
			word = line
			end	
		u = u+1
	end
	return word	
end
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
function ana_gen(word)
	local temp_word= {}
	local	word2 = {}
	local	d = {}
	for i =1,string.len(word) do
		word2[i] = string.sub(word,i,i)
	end	
	local k=1
	math.randomseed(os.time())
	while true do
		local temp = math.random(1,string.len(word))
		local flag = false
		for i = 1,k do
			if d[i] == temp then
				flag=false
				break
			elseif d[i] ~=temp then
				flag = true
			end	
		end
		if flag == true then
			d[k] = temp
			k=k+1
		end
		if table.getn(d) == string.len(word) then
				break
		end
	end
	for i=1,string.len(word) do
		temp_word[i] = word2[d[i]]
	end
	local	ana_word=""
	for i =1,string.len(word) do
		ana_word = ana_word..temp_word[i]
	end
	table.sort(temp_word)
	--for i =1,string.len(word) do
	--	print(temp_word[i])
	--end
	return ana_word	
end

function check(temp,temp2,d)
	local flag = false
	local k
	local i =1
	while true do
	if d[i] ~= nil then
		if temp ==d[i] then
			 k = i
			if temp2==d[k+1] then
				flag = true
			end
		end
		if temp2==d[i] then
			k=i
			if temp==d[k+1] then
				flag = true
			end
		end	
	i = i+2
	else 
		break
	end
	end
	if flag == true then
		return true
	end
	if flag == false then
		return false	
	end
end


function hints(word)
	math.randomseed(os.time())
	local d = {}
	local le = string.len(word)
	local i=1
	local k=0
	
	local hints = {"","","",""}
	local x=1
	local t
	while true do
		local temp = math.random(le)
		local temp2 = math.random(le)
		if temp~=temp2 then
			if check(temp,temp2,d)==false then
				
				d[i] = temp
				d[i+1] = temp2
				i=i+2
			end
		end
		if i > 8 then
			break
		end
	end
	local word2= {}
	for i =1,string.len(word) do
		word2[i] = string.sub(word,i,i)
	end
	for i=1,4 do
		for k=1,string.len(word) do
			t = x+1
			if k == d[x] or k==d[t] then
				hints[i] = hints[i]..word2[k].." "				
			else
				hints[i] = hints[i].."• "
			end					
		end
		x=t+1
	end
	return hints
end

