

var timeOutMS = 7000; //ms
 var stan=0;

var ajaxList = new Array();

function newAJAXCommand(url, container, repeat, data)
{
	
	var newAjax = new Object();
	var theTimer = new Date();
	newAjax.url = url;
	newAjax.container = container;
	newAjax.repeat = repeat;
	newAjax.ajaxReq = null;

	if(window.XMLHttpRequest) {
        newAjax.ajaxReq = new XMLHttpRequest();
        newAjax.ajaxReq.open((data==null)?"GET":"POST", newAjax.url, true);
        newAjax.ajaxReq.send(data);
   
    } else if(window.ActiveXObject) {
        newAjax.ajaxReq = new ActiveXObject("Microsoft.XMLHTTP");
        if(newAjax.ajaxReq) {
            newAjax.ajaxReq.open((data==null)?"GET":"POST", newAjax.url, true);
            newAjax.ajaxReq.send(data);
        }
    }
    newAjax.lastCalled = theTimer.getTime();
    ajaxList.push(newAjax);
}

function pollAJAX() {
	var curAjax = new Object();
	var theTimer = new Date();
	var elapsed;
	for(i = ajaxList.length; i > 0; i--)
	{
		curAjax = ajaxList.shift();
		if(!curAjax)
			continue;
		elapsed = theTimer.getTime() - curAjax.lastCalled;
				
	
		if(curAjax.ajaxReq.readyState == 4 && curAjax.ajaxReq.status == 200) 
		{
			
			if(typeof(curAjax.container) == 'function'){
				curAjax.container(curAjax.ajaxReq.responseXML.documentElement);
			} else if(typeof(curAjax.container) == 'string') {
				alert("string");
				document.getElementById(curAjax.container).innerHTML = curAjax.ajaxReq.responseText;
			} 
			
	    	curAjax.ajaxReq.abort();
	    	curAjax.ajaxReq = null;

			if(curAjax.repeat)
				newAJAXCommand(curAjax.url, curAjax.container, curAjax.repeat);
			continue;
		}
				
		if(elapsed > timeOutMS) {
		
			if(typeof(curAjax.container) == 'function'){
				curAjax.container(null);
			} else {
				
				alert("Command failed.\nConnection Lost.");
			}

	    	curAjax.ajaxReq.abort();
	    	curAjax.ajaxReq = null;
					
			if(curAjax.repeat)
				newAJAXCommand(curAjax.url, curAjax.container, curAjax.repeat);
			continue;
		}
		ajaxList.push(curAjax);
	}
	
        setTimeout("pollAJAX()",100);
	
}

function getXMLValue(xmlData, field) {
	try {
		if(xmlData.getElementsByTagName(field)[0].firstChild.nodeValue)
			return xmlData.getElementsByTagName(field)[0].firstChild.nodeValue;
		else
			return null;
	} catch(err) { return null; }
}
var out_stan=Array(4);

function C(a)
{
   return (document.getElementById(a).checked);


}

function V(a)
{
   return (document.getElementById(a).value);


}

function zdarzenie() {
var out='';

if (V('o0')== '1')
{
if(out_stan[0]==0)
{
out='0';	
}
}
else
{
if(out_stan[0] == 1)
{
out=out+'0';	
}
}

if (V('o1')== '1')
{
if(out_stan[1]==0)
{
out=out+'1';
}
}
else
{
if(out_stan[1] == 1)
{
out=out+'1';	
}
}
if (V('o2')== '1')
{
if(out_stan[2]==0)
{
out=out+'2';
}
}
else
{
if(out_stan[2] == 1)
{
out=out+'2';
}
}
if (V('o3')== '1')
{
if(out_stan[3]==0)
{
out=out+'3';
}
}
else
{
if(out_stan[3] == 1)
{
out=out+'3';
}
}
if (V('o4')== '1')
{
if(out_stan[4]==0)
{
out=out+'4';
}
}
else
{
if(out_stan[4] == 1)
{
out=out+'4';
}
}
if (V('o5')== '1')
{
if(out_stan[5]==0)
{
out=out+'5';
}
}
else
{
if(out_stan[5] == 1)
{
out=out+'5';
}
}

newAJAXCommand('outs.cgi?out='+out)

}

function updateSave(xmlData) {
	
	if(!xmlData)
	{
	return;
	}

	if (getXMLValue(xmlData, 'U')=='1')
	document.getElementById('vin').innerHTML = "DONE";
		else
	document.getElementById('vin').innerHTML = "WAIT";
	
}

function updateEvents(xmlData) {
	
	if(!xmlData)
	{
		return;
	}

	var ind='TWXYZURV';
    var indd='FG';
	var tab,dane;
	for (i=0;i<8;i++)
	{
		dane=getXMLValue(xmlData, 'Z'+i);
		tab=dane.split('*');
						
	
	
		for(j = 0; j < 18; j++)
		{
	
			if (j==17)
			document.getElementById(ind.charAt(i)+j).value= tab[j];
			else 
            {
                if (i==7)
                    document.getElementById(ind.charAt(i)+j).value=parseFloat(tab[j]/100).toFixed(2);
                else
                    document.getElementById(ind.charAt(i)+j).value=parseFloat(tab[j]/10).toFixed(1);
            }
		
		}
		
				
		
		if (i<8)
		{
		dane=getXMLValue(xmlData, 'EV');
		document.getElementById(ind.charAt(i)+'20').checked=dane&(1<<(i));
		}
		
	}

	for (i=0;i<6;i++)
	{
		document.getElementById('O'+i).value=getXMLValue(xmlData, 'o'+i);
       
        if(i<2) //tylko 2 INPD
        {
        	dane=getXMLValue(xmlData, 'DZ'+i);
            tab=dane.split('*');    
        
             for(j = 0; j < 8; j++)
        	document.getElementById(indd.charAt(i)+(j+4)).checked=tab[0]&(1<<(j));
            document.getElementById(indd.charAt(i)+2).value=tab[1];
    
        }
         
        

	}
    d=getXMLValue(xmlData, 'a0');
	for (i=0;i<8;i++)
    {
	document.getElementById('tb'+i).checked=d&(1<<(i));
    document.getElementById('1'+i).value=getXMLValue(xmlData, 'b'+i);
    }

    document.getElementById('tb8').value=getXMLValue(xmlData, 'Z8');
}

function updateStatus(xmlData) {
	
	var a=10,i,c;
	if(!xmlData)
	{
		
		document.getElementById('loading').style.display = 'inline';
		
		return;
	}

	
	document.getElementById('loading').style.display = 'none';
	
	c=getXMLValue(xmlData, 'out6');
	
	for(i = 0; i < 6; i++) {
		if(getXMLValue(xmlData, 'out'+i) != c)
		{
			document.getElementById('out' + i).style.background = 'red';
			document.getElementById('ot'+i).innerHTML = "OFF";
			document.getElementById('ot'+i).style.color = "red";
			
			out_stan[i]=1;
						
		}
		else
		{
			document.getElementById('out' + i).style.background = 'green';
			document.getElementById('ot'+i).innerHTML = "ON_";
			document.getElementById('ot'+i).style.color = "green";
			
			out_stan[i]=0;
						
			}
	}
	

	
	for(i = 0; i < 9; i++) {
        if(i==7)//inpV
        c=parseFloat(getXMLValue(xmlData, 'ia'+i)/100).toFixed(2);
            else     
        c=parseFloat(getXMLValue(xmlData, 'ia'+i)/10).toFixed(1);
        if (c<-55)
        c="N/A";
        document.getElementById('inp'+i).innerHTML = c;
	}
	

	
	for(i = 0; i < 4; i++) {
	document.getElementById('workt'+i).innerHTML = getXMLValue(xmlData, 'sec'+i);	
	}
	document.getElementById('workt4').innerHTML = gmtime(getXMLValue(xmlData, 'sec4'))[0];	
	
    for(i = 0; i < 2; i++) {
		if(getXMLValue(xmlData, 'di'+i) == 'up')
                    {
			document.getElementById('di'+i).innerHTML = 'HIGH';
            document.getElementById('di'+i).style.color = "green";
                    }
		else{
			document.getElementById('di'+i).innerHTML = 'LOW_';
            document.getElementById('di'+i).style.color = "red";
                }
	}
	
}

function updateS2(xmlData) {
var d,a,b,i,g,h,c;
d=getXMLValue(xmlData, 'out6');
document.getElementById('r_st').checked=!(d&1);

document.getElementById('ver').innerHTML = getXMLValue(xmlData, 'ver');
document.getElementById('hw').innerHTML = getXMLValue(xmlData, 'hw');
document.getElementById('na').innerHTML = getXMLValue(xmlData, 'na');
for(i = 0; i < 6; i++) {
document.getElementById('o'+i).value = getXMLValue(xmlData, 'out'+i);


d=getXMLValue(xmlData, 'd');    
   
g=d.split('*');

h=getXMLValue(xmlData, 'a');
c=h.split('*');

for(i = 0; i < 12; i++)
    {
    document.getElementById('r_t'+i).value = getXMLValue(xmlData, 'r'+i);
    document.getElementById('a'+i).value = c[i];
     if (i<9)
    document.getElementById('d'+i).value = g[i];
    }
    }
    d=getXMLValue(xmlData, 'as');
    for(i = 0; i < 6; i++)
        {
   document.getElementById('ae'+i).checked=d&(1<<(i));
 
        }

}

function updateEventsM(xmlData) {
for(i = 0; i < 6; i++) {
document.getElementById('e'+i).value = getXMLValue(xmlData, 'e'+i);
}

}

function updateSchTime(xmlData){
document.getElementById('t0').innerHTML = gmtime(getXMLValue(xmlData, 't'))[0];
}


function updateEventsW(xmlData) {
var ind='ABCDEH';
	var tab,dane,a;
	for (i=0;i<6;i++)
	{
		dane=getXMLValue(xmlData, 'w'+i);
		tab=dane.split('*');
		for(j = 1; j < 4; j++) 
		document.getElementById(ind.charAt(i)+j).value=tab[j];
		
			document.getElementById(ind.charAt(i)+'0').checked=tab[0]&4;
			document.getElementById(ind.charAt(i)+'4').checked=(!(tab[0]&1) && !(tab[0]&2));
			document.getElementById(ind.charAt(i)+'5').checked=tab[0]&1;
			document.getElementById(ind.charAt(i)+'6').checked=tab[0]&2;
                        document.getElementById(ind.charAt(i)+'7').checked=tab[0]&8;
		}
		document.getElementById('F0').value=getXMLValue(xmlData, 'w6');
		document.getElementById('G0').value=getXMLValue(xmlData, 'w7');

}

function updateEventsS(xmlData) {
var ind='ABCDEFGHIJ';
	var tab,da,a;
	for (i=0;i<10;i++)
	{
	a=',';
		da=getXMLValue(xmlData, 's'+i);
		tab=da.split('*');
		 for (j=0;j<8;j++)
		if ((tab[3]>>j)&1)
		a=a+we.substr(j*2,2)+',';
		
			document.getElementById(ind.charAt(i)+'3').value=tab[2]+a+gmtime(tab[4])[1];
			document.getElementById(ind.charAt(i)+'2').value=tab[1];
		
			document.getElementById(ind.charAt(i)+'0').checked=tab[0]&4;
			document.getElementById(ind.charAt(i)+'4').checked=(!(tab[0]&1) && !(tab[0]&2) && !(tab[0]&8));
			document.getElementById(ind.charAt(i)+'5').checked=tab[0]&1;
			document.getElementById(ind.charAt(i)+'6').checked=tab[0]&2;
                        document.getElementById(ind.charAt(i)+'7').checked=tab[0]&8;
                        
		}

}

function updateBoard(xmlData) {
var d,i;
		d=getXMLValue(xmlData, 'a0');
		
			if (d=='1')
			d=1;
			else
			d=0;
			document.getElementById('b0').checked=d;
			document.getElementById('b1').checked=!d;
			document.getElementById('b2').disabled=d;
			
			d=getXMLValue(xmlData, 'a1');
			for (i=0;i<7;i++)
			document.getElementById('te'+i).checked=d&(1<<(i));
			document.getElementById('Tt').value=getXMLValue(xmlData, 'a2');

			ch_t();
			w_min(document.getElementById('Tt').value);
			
			for (i=0;i<27;i++)
			{
			document.getElementById('e'+i).value=getXMLValue(xmlData, 'b'+i)
			}
            document.getElementById('e30').value=getXMLValue(xmlData, 'b30');
            document.getElementById('e31').value=getXMLValue(xmlData, 'b31');

                        for (i=27;i<30;i++)
			document.getElementById('e'+i).checked=getXMLValue(xmlData, 'b'+i);
			configIPBoxes();
			document.getElementById('b2').value=gmtime(getXMLValue(xmlData, 'c'))[0]

            d=getXMLValue(xmlData, 'r0');

			document.getElementById('rs0').checked=d&1;
			document.getElementById('rs1').value=getXMLValue(xmlData, 'r1');
			document.getElementById('rs2').value=getXMLValue(xmlData, 'r2');
			remote();
						
}


function test() {
newAJAXCommand('email.cgi',0,0,'test');
//newAJAXCommand('m.xml', updateEventsM, false);

}
function save_mail() {
var a,b,c,d,e,f,g,dane;
a='serw='+V('e0');
b='&port='+V('e1');
c='&user='+V('e2');
d='&pass='+V('e3');
e='&to='+V('e4');
f='&from='+V('e5');
g='&sub='+V('e26');
dane=a+b+c+d+e+f+g;
newAJAXCommand('index.htm',0,0,dane);
//newAJAXCommand('m.xml', updateEventsM, false);

}


function save_sn()
{

a='user='+V('e14');
b='&pass='+V('e15');
a1='&use2='+V('e30');
b1='&pas2='+V('e31');
c='&N1='+V('e16');
d='&N2='+V('e17');
e='&N3='+V('e18');
f='&N4='+V('e19');
g='&rcm0='+V('e20');
h='&rcm1='+V('e21');
j='&wcm0='+V('e22');
k='&wcm1='+V('e23');
m='&T1='+V('e24');
n='&T2='+V('e25');
o='&T0='+C('e28');
p='&aut='+C('e29');
dane=a+b+a1+b1+c+d+e+f+g+h+j+k+m+n+o+p;
newAJAXCommand('config.htm',0,0,dane);


}


function save_b() {
var a,b,c,d,e,f,g,h,k,dane,ta,da,cz;
if (C('te0'))c=c|1;if (C('te1'))c=c|2;if (C('te2'))c=c|4;if (C('te3'))c=c|8;if (C('te4'))c=c|0x10;
if (C('te5'))c=c|0x20;if (C('te6'))c=c|0x40;


if (C('rs0'))g=g|1;else g=g&0xfe;

a='ntp='+C('b0');
dane=V('b2');
ta=dane.split(';');
da=ta[0].split('-');
cz=ta[1].split(':');
b='&time='+DataToNtp(da[0],da[1],da[2],cz[0],cz[1],cz[2]);
c='&tre='+c;
d='&trt='+V('Tt');
g='&rsc='+g;
h='&rsp='+V('rs1');
k='&rps='+V('rs2');
dane=a+b+c+d+f+g+h+k;
newAJAXCommand('index.htm',0,0,dane);


}

function configIPBoxes() {
var i,d;
	if (C('e27'))
	d=1;
	else
	d=0;
	for (i=8;i<13;i++)
	document.getElementById('e'+i).disabled=d;
}


function w_min(a) {

document.getElementById('min').innerHTML=parseFloat((a*10)/60).toFixed(2);
}
function ch_t() {
var i;
for (i=1;i<7;i++)
document.getElementById('te'+i).disabled=!document.getElementById('te0').checked ;
document.getElementById('Tt').disabled=!document.getElementById('te0').checked 
}

function change_t() {
	
document.getElementById('b2').disabled=document.getElementById('b0').checked ;
		
}
function remote()
{
var i;
	for (i=1;i<3;i++)
	if (C('rs0'))
	document.getElementById('rs'+i).disabled=0;
	else
	document.getElementById('rs'+i).disabled=1;


}


function save_dog(k) {
var a=0,b=0,c=0,d=0,e=0,f=0,g=0,h=0,i=0,j=0,da;

if (C('A0'))a=4;
if (C('A5'))a=a|1;
if (C('A6'))a=a|2;

if (C('B0'))b=4;
if (C('B5'))b=b|1;
if (C('B6'))b=b|2;

if (C('C0'))c=4;
if (C('C5'))c=c|1;
if (C('C6'))c=c|2;

if (C('D0'))d=4;
if (C('D5'))d=d|1;
if (C('D6'))d=d|2;

if (C('E0'))e=4;
if (C('E5'))e=e|1;
if (C('E6'))e=e|2;

if (C('H0'))h=4;
if (C('H5'))h=h|1;
if (C('H6'))h=h|2;

if (C('A7'))a=a|8;
if (C('B7'))b=b|8;
if (C('C7'))c=c|8;
if (C('D7'))d=d|8;
if (C('E7'))e=e|8;

if(k==1)
{



a='IP0=0*'+a+'*'+V('A2')+'*'+V('A1')+'*'+V('A3');
b='&IP1=0*'+b+'*'+V('B2')+'*'+V('B1')+'*'+V('B3');
c='&IP2=0*'+c+'*'+V('C2')+'*'+V('C1')+'*'+V('C3');
d='&IP3=0*'+d+'*'+V('D2')+'*'+V('D1')+'*'+V('D3');
e='&IP4=0*'+e+'*'+V('E2')+'*'+V('E1')+'*'+V('E3');
h='&IP5=0*'+h+'*'+V('H2')+'*'+V('H1')+'*'+V('H3')+'*'+V('F0')+'*'+V('G0');
da=a+b+c+d+e+h;
newAJAXCommand('watchdoog.htm',0,0,da);
}
else
{
h=0;
if (C('F0'))f=4;
if (C('F5'))f=f|1;
if (C('F6'))f=f|2;
if (C('F7'))f=f|8;

if (C('G0'))g=4;
if (C('G5'))g=g|1;
if (C('G6'))g=g|2;
if (C('G7'))g=g|8;

if (C('H0'))h=4;
if (C('H5'))h=h|1;
if (C('H6'))h=h|2;
if (C('H7'))h=h|8;
if (C('I0'))i=4;
if (C('I5'))i=i|1;
if (C('I6'))i=i|2;
if (C('I7'))i=i|8;
if (C('J0'))j=4;
if (C('J5'))j=j|1;
if (C('J6'))j=j|2;
if (C('J7'))j=j|8;

a='S0=0*'+a+'*'+V('A2')+'*'+sche('A3')[0]+'*'+sche('A3')[1]+'*'+sche('A3')[2];
b='&S1=0*'+b+'*'+V('B2')+'*'+sche('B3')[0]+'*'+sche('B3')[1]+'*'+sche('B3')[2];
c='&S2=0*'+c+'*'+V('C2')+'*'+sche('C3')[0]+'*'+sche('C3')[1]+'*'+sche('C3')[2];
d='&S3=0*'+d+'*'+V('D2')+'*'+sche('D3')[0]+'*'+sche('D3')[1]+'*'+sche('D3')[2];
e='&S4=0*'+e+'*'+V('E2')+'*'+sche('E3')[0]+'*'+sche('E3')[1]+'*'+sche('E3')[2];
f='&S5=0*'+f+'*'+V('F2')+'*'+sche('F3')[0]+'*'+sche('F3')[1]+'*'+sche('F3')[2];
g='&S6=0*'+g+'*'+V('G2')+'*'+sche('G3')[0]+'*'+sche('G3')[1]+'*'+sche('G3')[2];
h='&S7=0*'+h+'*'+V('H2')+'*'+sche('H3')[0]+'*'+sche('H3')[1]+'*'+sche('H3')[2];
i='&S8=0*'+i+'*'+V('I2')+'*'+sche('I3')[0]+'*'+sche('I3')[1]+'*'+sche('I3')[2];
j='&S9=0*'+j+'*'+V('J2')+'*'+sche('J3')[0]+'*'+sche('J3')[1]+'*'+sche('J3')[2];
da=a+b+c+d+e+f+g+h+i+j;
newAJAXCommand('index.htm',0,0,da);

}

}
var we="MoTuWeThFrSaSu##";
function sche(m)
{
var da,l=-2,day=0;
da=document.getElementById(m).value.split(',');
for(i=0;i<9;i++)
if(da[i])
l++;
for(i=l;i>0;i--)
	for(j=0;j<8;j++)
	if (da[i]==we.substr(j*2,2))
	day=day|(1<<j);

l=da[l+1].split(':');
l[0]=l[0]*3600;
l[1]=l[1]*60;
l[2]=l[0]+l[1]+(l[2]*1);
return [da[0],day,l[2]];	
}

function m12(is,m)
{
	if(m==1)
	{
		return(28+is);
	}
	if (m>6)
	{
		m--;
	}
	if (m%2==1)
	{
		return(30);
	}
	return(31);
}
function LEA(ye)
{
var a,b;
a=!((ye) % 4);
if(((ye) % 100) || !((ye) % 400))
b=1;
else
b=0;
	return(a && b);
}

function YEA(ye)
{
return(LEA(ye) ? 366 : 365)
}

function DataToNtp (r,m,d,g,mi,s)
{
var E_YR=1970;

var	S_DAY=86400;  
 r_s=0;
m_s=0;
d_s=0;
 h_s=0;
 mi_s=0;
var i;

for (i=0;i<mi;i++)
mi_s=mi_s+60;


for (i=0;i<g;i++)
h_s=h_s+3600;

for (i=0;i<(d-1);i++)
d_s=d_s+S_DAY;

for (i=0;i<m-1;i++)
m_s=m_s+m12(LEA(r),i);

m_s=m_s*S_DAY;
r_s=(r-E_YR)*31536000+(Math.floor((r-E_YR)/4))*S_DAY;

return (r_s+m_s+d_s+h_s+mi_s+(s*1));
}
function Ze(l)
{
var w=l+'' ;
while(w.length < 2) 
w = "0" + w;
return (w);
}

function gmtime(time)
{
       
var i,j,k,dc,day,ms,mm,mh,mmm,year = 1970;

	dc = time % 86400;
	day = Math.floor(time / 86400);

	ms = dc % 60;
	mm = Math.floor((dc % 3600) / 60);
	mh = Math.floor(dc / 3600);
	
	while (day >= YEA(year)) {
		day -= YEA(year);
		year++;
	}
	
	mmm = 0;
	
	while (day>= m12(LEA(year),mmm))
	{
		day -= m12(LEA(year),mmm);
		mmm++;
	}
    
	mmm=Ze(mmm+1);
	day=Ze(day+1);
	i=Ze(mh)+':'+Ze(mm)+':'+Ze(ms);
	return [year+'-'+mmm+'-'+day+';'+i,i];
}
setTimeout("pollAJAX()",200);
