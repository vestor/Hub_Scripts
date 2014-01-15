import socket
import Queue
import netaddr
import threading
import time
import datetime
import array
def readsock(sock):
        buff = ""
        sock.settimeout(0.13)
        while True:
            try:
                while True:
                    t = sock.recv(1)
                    if t != '|': buff += t
                    else: return buff
            except socket.timeout:            
                pass   
            except socket.error, msg:
                return         
        return buff
def to_key(lock):
        
        lock = array.array('B', lock)
        ll = len(lock)
        key = list('0'*ll)
        for n in xrange(1,ll):
            key[n] = lock[n]^lock[n-1]
        key[0] = lock[0] ^ lock[-1] ^ lock[-2] ^ 5
        for n in xrange(ll):
            key[n] = ((key[n] << 4) | (key[n] >> 4)) & 255
        result = ""
        for c in key:
            if c in (0, 5, 36, 96, 124, 126):
                result += "/%%DCN%.3i%%/" % c
            else:
                result += chr(c)
        return result


def xecute(IP):
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.settimeout(0.13)
    try:
        serversocket.connect((IP,411))
        
    except: return
    c=0
    while 1:
        c = c+1
        try:
            t = readsock(serversocket)
            
        except: return
        if t!='':            
            if t[0] =='$':
                hubmsg = t.split()
                if hubmsg[0] == '$Lock':                    
                    serversocket.send("$Key "+to_key(hubmsg[1])+"|"+"$ValidateNick "+"Darks"+"|")
                if hubmsg[0]=='$Hello':
                    serversocket.send('$MyINFO $ALL '+'Darks'+' simple python bot$ $DSL$bot@bot.com$'+str(1024*1024*1024*100)+'$|')
                if hubmsg[0]=='$HubName':                    
                    x = ' '.join(hubmsg[1:])
                    serversocket.close()
                    z=[]
                    
                    for i in list(x):
                            if i=="\xa0":
                                    c=" "
                            else:
                                    c= i
                            z.append(c)
                    z = ''.join(z)
                    return z
            else:
                    return "Name not resolved"
    return None

def filewrite2(data2):
    now = datetime.datetime.now()
    if data2 != None:
        ser = open("hubs2.txt","w")
        ser.write("\n\n")
        ser.write("\n             CURRENT HUBS RUNNING ON LAN\n")
        ser.write("\n============================================================\n")
        ser.write("                    Last Updated:       "+str(now.hour)+":"+str(now.minute)+":"+str(now.second)+" "+str(now.day)+"/"+str(now.month)+"/"+str(now.year)+"\n")
        ser.write("\n===============HUB IP===============HUB-NAME===============\n")
    for el in data2:
            print el[0],el[1]
            ser.write("             Join     dchub://"+str(el[0])+"         "+str(el[1])+"\n")
    ser.close()
        


qu = Queue.Queue(0)

class client(threading.Thread):
    def run(self):
        global HUBS
        global DESC
        ip = None
        for i in range(60):
            
            if qu.empty():
                #HUBS = DESC    
                break
            flag = False
            try:
                ip = qu.get_nowait()
            except:break
            flag = False
            x = xecute(ip)
            
            if x!=None and len(x)>1:
                    
                flag = True
            if flag==True and (ip,x) not in HUBS:
                
                HUBS.append((ip,x))
                
                
    
txt = open("subnetlist.txt")
tmp = txt.read()
subnetList = tmp.split('\n')
HUBS =[]
DESC = []
def discover():
    print "Discovery started for HUBS"
    global HUBS
    
    global DESC
    for x in range(200):
        client().start()
        client().Daemon = True
    for subnet in subnetList:
        for i in netaddr.IPNetwork(subnet):
            qu.put('%s' % i)
    k = 0
    while threading.activeCount() > 1:
        print threading.activeCount()
        k=k+1
        if k > 20:
            break
        time.sleep(1)
    DESC = HUBS    
    #HUBS=[]    
        #return recieved
t = 10
while True:
    if HUBS != [] and len(HUBS) > 1 :
            print HUBS
            filewrite2(HUBS)
    #else:
    #        print DESC
    #        filewrite2(DESC)
    if t<=(80):
        t = t + 10
    else: t = 10
        
    time.sleep(t)
    HUBS= []
    #DESC = []
    discover()
    
    
    
    
    



