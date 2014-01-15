import datetime
import struct
import Queue
import time
import threading
import netaddr
import socket

socket.setdefaulttimeout(0.05)

def filewrite(d = None):
        now = datetime.datetime.now()
        e="        "
        ser = open("CS.txt","w")
        ser.write("\n|                               Counter Strike's Servers' List      \n\n")
        ser.write("\n                    Last Updated:       "+str(now.hour)+":"+str(now.minute)+":"+str(now.second)+" "+str(now.day)+"/"+str(now.month)+"/"+str(now.year)+"\n")
        ser.write("\n            Server Name   I   Players    I       IP        I   Server Map       \n")
        if d != None:
            for el in d:
                ser.write("\n            "+el[1][0]+e+str(el[1][4][0])+"/"+str(el[1][4][1])+e+el[0]+e+el[1][1]+e+"\n")
                ser.write("         --------==-----------=-----------------=-------------=-----------=-------------")
        else:
            ser.write("\n\n         --------==-----------=-----------------=-------------=-----------=--------\n\n\n")
        ser.write("\n\n           You can also visit http://172.16.15.147/games/ for a better view :P and quick updation|\n")
        ser.close()
def HTMLwrite(DATAX=None):
    if DATAX!=None:
        ser = open("CS.txt","w")
        data = []
        
        for el in DATAX:
            ser.write("<tr>")
            ser.write("<td>"+el[1][0]+"</td>")
            ser.write("<td>"+str(el[1][4][0])+"/"+str(el[1][4][1])+"</td>")
            ser.write("<td>"+el[0]+"</td>")
            ser.write("<td>"+el[1][1]+"</td>")
            ser.write("</tr>")        
        ser.close()
    else:
        ser = open("CS.txt","w")
        ser.write("<tr><td>None</td><td>None</td><td>None</td><td>None</td></tr>")
        ser.close()

def Info(txt):
    txt=txt.replace('\377', '')
    #if txt.find('m') == 0:
    serv_name=txt.split('\0') [1]
    serv_map=txt.split('\0') [2]
    serv_engine=txt.split('\0') [3]
    serv_game=txt.split('\0') [4]
    players = struct.unpack('bb',txt.split('\0')[5][:2])
        
    return (serv_name,serv_map,serv_engine,serv_game,players)
    
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
                s.connect((ip,27015))
            except Exception,e:
                s.close()
                print e
                break
            s.send('\xFF\xFF\xFF\xFF\x54\x53\x6F\x75\x72\x63\x65\x20\x45\x6E\x67\x69\x6E\x65\x20\x51\x75\x65\x72\x79\x00')
            s.settimeout(0.05)
            while 1:
                try:
                    data,addr = s.recvfrom(1024)
                except Exception ,e:
                    break               
                if not data:
                    break
                flag = True
                data2 = Info(data)
                tmp = (ip,data2)
                if len(data)>5:
                    break
                else:
                    flag=False
                    break
                
            if flag:
                if tmp not in SERVERS:
                    SERVERS.append(tmp)


            s.shutdown(socket.SHUT_RDWR)
            s.close()


txt = open("subnetlist.txt")
tmp = txt.read()
subnetList = tmp.split('\n')

qu = Queue.Queue(0)
global SERVERS
SERVERS= []

def discover():
    print "Discovery started CS"
    global SERVERS
    
    for x in range(200):
        client().start()
        client().Daemon = True

    for subnet in subnetList:
        for i in netaddr.IPNetwork(subnet):
            qu.put('%s' % i)
    while threading.activeCount() > 1:
        print threading.activeCount()
        time.sleep(1)
    #qu.join()
count = 0
while True:
    
    print SERVERS
    if SERVERS ==[]:
        count+=1
        if count > 2:
            HTMLwrite()
            filewrite()
            count = 0            
    else:
        HTMLwrite(SERVERS)
        filewrite(SERVERS)   
    SERVERS = []
    discover()
    time.sleep(5)
