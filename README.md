# LAST Matlab class to control the tinycontrol IP power socket v2 (LANLIS-010)

6 outlets, interacted with via authenticated http queries on port 80. The status of the outlets is
 commanded by sending appropriate parameters to a script `outs.cgi` of the device webby, much of the configuration
can be read retrieving one among 7 xml datafiles, but there seems to be no documented way to change programmatically
the configuration if not through the webby.

Maybe interaction is possible via form PUTS, I'm not familiar with that too, though webpages include also some javascript. There are many `<input>` tags in the page source, they may be well html forms, but we have then to map the id of every possible field.

The pages of the webby in any event are:

- http://192.168.1.100/index.htm
- http://192.168.1.100/in_config.htm
- http://192.168.1.100/watchdoog.htm *(yes, two oo)*
- http://192.168.1.100/scheduler.htm
- http://192.168.1.100/config.htm

where 192.168.1.100 is the default IP of the device.

It should also be possible to access 20 parameters by SNMP but I'm not familiar with that.

- [manual of the thing](https://www.ledats.pl/en/index.php?controller=attachment&id_attachment=326)

The thing has a recessed Reset button. I rather think that this sends a Reset event to the sockets
 (power cycles them if so defined in the configuration, rather than resetting some configuration).
Whith the default configuration it does a very dumb action, it simply inverts the present on/off status
of the 6 sockets.

The reboot button midway in the Network config page calls `http://192.168.1.100/reboot.htm?192.168.1.100`.

Analyzing the page sources I also found this queries:

- `ind.cgi?ae=` + number
- `ind.cgi?a` + number `=` + number
- `ind.cgi?d` + number `=` + number

whose purpose seems to be only to change the status of the indicators on the web page.

I wonder if there is a way to factory reset the device, for instance to restore the default IP
 and username and password in case they have been messed up with.

NB: webread queries with this class are much faster if the webby is **not** looked at in a web browser. Typical times to read the status of all outputs (parsing `st0.xml`) and for setting a single output (via `outs.cgi`) are of the order of 300ms.