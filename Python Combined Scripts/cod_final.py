import datetime

DATA=[]
import Queue
import time
import threading
import netaddr
import socket
import re

def filewrite(d = None):
        now = datetime.datetime.now()
        e="     "
        ser = open("COD.txt","w")
        ser.write("\n|                               Call Of Duty Servers' List      \n")
        ser.write("\n                    Last Updated:       "+str(now.hour)+":"+str(now.minute)+":"+str(now.second)+" "+str(now.day)+"/"+str(now.month)+"/"+str(now.year)+"\n")
        ser.write("\n     Server Name   I   Players    I          IP           I         Server Map        I        GameType       I    Version    \n")
        if d != None:
            for el in d:
                ser.write("\n"+el[1][1].rjust(17," ")+el[1][2].rjust(17," ")+el[0].rjust(20," ")+el[1][0].rjust(26," ")+str(el[1][3]).rjust(25," ")+el[1][4].rjust(13," ")+"\n")
        
        else:
            ser.write("\n\n       --------==-----------=-----------------=-------------=-----------=-----------------=-----------=----------= \n\n\n")
        ser.write("\n\n You can also visit http://172.16.15.147/games/ for a better view :P and quick updation |\n")
        ser.close()
def HTMLwrite(DATAX=None):
    if DATAX!=None:
        ser = open("COD.txt","w")
        data = []
        
        for el in DATAX:
            ser.write("<tr>")
            ser.write("<td>"+el[1][1]+"</td>")
            ser.write("<td>"+el[1][2]+"</td>")
            ser.write("<td>"+el[0]+"</td>")
            ser.write("<td>"+el[1][0]+"</td>")
            ser.write("<td>"+str(el[1][3])+"</td>")
            ser.write("<td>"+el[1][4]+"</td>")
            ser.write("<td>"+el[1][5]+"</td>")
            ser.write("<td>"+el[1][7]+"</td>")
            print el[1][7]
            stri = ""
            for it in range(len(el[1][8])):
                    stri = stri + "<option value = \""+str(it+1)+"\">"+str(el[1][8][it])+"</option>"
            ser.write("<td>"+"<select name=\"players\">"+stri+"</td>")
            ser.write("</tr>")        
        ser.close()
    else:
        ser = open("COD.txt","w")
        ser.write("<tr><td>None</td><td>None</td><td>None</td><td>None</td><td>None</td><td>None</td></tr>")
        ser.close()

socket.setdefaulttimeout(0.05)
def resolve_gametype(x):
    if x=='war':
        return 'Team Deathmatch'
    elif x=='sd':
        return 'Search and Destroy'
    elif x=='dom':
        return 'Domination'
    elif x=='dm':
        return 'Free-for-All'
    elif x=='koth':
        return 'Headquarters'
    elif x=='sab':
        return 'Sabotage'
def info(datax):
    x = datax
    pb = x[(x.find("punkbuster")+11):x.find("\\",(x.find("punkbuster")+11))]
    
    if  pb == "0":
            punkbuster = "No"
    else:
            punkbuster = "Yes"
    pas = x[(x.find("pswrd")+6):x.find("\\",(x.find("pswrd")+6))]
    if  pas == "0":
            passw = "No"
    else:
            passw = "Yes"

    fs_game = x.find("fs_game")
    
    if fs_game != -1 :
            mod_name = x[(x.find("mods")+5):x.find("\\",(x.find("mods")+5))]
    else:
            mod_name = "NO MOD"
    print mod_name    

    player = [m.start() for m in re.finditer('\"', x)]
    
    player_names = []
    for y in range(len(player)/2):
            player_names.append(x[player[2*(y)]+1:player[2*(y)+1]])
             
    
    mapname=x[(x.find("mapname")+8):x.find("\\",(x.find("mapname")+8))]
    hostname = x[(x.find("hostname")+9):x.find("\\",(x.find("hostname")+9))]
    if x.find('"')>0:
        players = str(x.count('"')/2)
        #[(x.find("\\clients\\")+9):x.find("\\",(x.find("\\clients\\")+9))]
    else: players = "0"
    max_clients = x[(x.find("sv_maxclients")+14):(x.find("\\",(x.find("sv_maxclients")+14)))]
    players = players+"/"+max_clients
    version = x[(x.find("version")+8):x.find("\\",(x.find("version")+8))]
    game_type=resolve_gametype(x[(x.find("gametype")+9):(x.find("\\",(x.find("gametype")+9)))])
    return (mapname,hostname,players,game_type,version,punkbuster,passw,mod_name,player_names)

class client(threading.Thread):   
    def run (self):
        global SERVERS
        global DATA
        ip = None
        for x in range(60):
            if qu.empty():
                break
            flag = False
            try:
                ip = qu.get_nowait()
            except: break
            
            s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
            try:
                s.connect((ip,28960))
            except Exception,e:
                s.close()
                print e
                break
            s.send('\xFF\xFF\xFF\xFFgetstatus\x00')
            s.settimeout(0.05)
            while 1:
                try:
                    data,addr = s.recvfrom(1024)
                    print data
                except Exception ,e:
                    break               
                if not data:
                    break
                flag = True
                data2 = info(data)
                tmp = (ip,data2)
                if len(data)>5:
                    break
                else:
                    flag=False
                    break
                
            if flag:
                if tmp not in DATA:
                    DATA.append(tmp)


            s.shutdown(socket.SHUT_RDWR)
            s.close()
            
txt = open("subnetlist.txt")
tmp = txt.read()
subnetList = tmp.split('\n')

qu = Queue.Queue(0)


def discover():
    print "Discovery started COD"
    global SERVERS
    global DATA
    
    for x in range(200):
        client().start()
        client().Daemon = True

    for subnet in subnetList:
        for i in netaddr.IPNetwork(subnet):
            qu.put('%s' % i)
    while threading.activeCount() > 1:
        print threading.activeCount()
        time.sleep(1)
    

count = 0
while True:
    
    print DATA
    if DATA ==[]:
        count+=1
        if count > 1:
            HTMLwrite()
            count = 0
            filewrite()
    else:
        HTMLwrite(DATA)
        filewrite(DATA)
           
    DATA = []
    discover()
    time.sleep(5)
