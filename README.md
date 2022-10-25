# LAST Matlab class to control the tinycontrol IP power socket v2 (LANLIS-010)

6 outlets, max 10A total current. The [manual](https://www.ledats.pl/en/index.php?controller=attachment&id_attachment=326) of the thing used to be
[here](https://www.ledats.pl/en/index.php?controller=attachment&id_attachment=326).

The thing has a recessed Reset button. I suppose that this sends a Reset event to the sockets
 (power cycles them if so defined in the configuration, rather than resetting some configuration).
Whith the default configuration it does something very dumb: it simply inverts the present on/off
 status of the 6 sockets. I haven't yet understood if it can do more than that.

At power on, sockets are turned on only if the checkmarks of the "On Delay" in the Events page
 are checked.
 Otherwise, the default power on state seems to be with all sockets off. When changed, the save configuration
 button needs to be pressed. The setting fortunately survives power down, it is probably saved in flash.

I wonder if there is a way to factory reset the device, for instance in order to restore the default IP
 and username and password in case they have been messed up with.


## Commanding, via http

The documented way implies authenticated http queries on port 80. The status of the
outlets is commanded by sending appropriate parameters to a script `outs.cgi` of the device webby.
 While much of the configuration can be read retrieving one among 7 xml datafiles, there seems to
 be no documented way to change programmatically the configuration if not through the webby.

The pages of the webby in any event are:

- http://192.168.1.100/index.htm
- http://192.168.1.100/in_config.htm
- http://192.168.1.100/watchdoog.htm *(yes, two oo)*
- http://192.168.1.100/scheduler.htm
- http://192.168.1.100/config.htm

where 192.168.1.100 is the default IP of the device.

Maybe interaction is possible via form PUTS, I'm not familiar with that too, though webpages include also some javascript. There are many `<input>` tags in the page source, they may be well html forms, but we have then to map the id of every possible field.

**NB:** webread queries with this class are much faster if the webby is **not** looked at in a web browser.
 Typical times to read the status of all outputs (parsing `st0.xml`) and for setting a single output
 (via `outs.cgi`) are of the order of 300ms.


## Peeks from the code of the webby

The "Save configuration" button on the Events page calls `in_config.htm` (the same Events page) with a long
string built upon the entry on that page.

The reboot button midway in the Network config page calls `http://192.168.1.100/reboot.htm?192.168.1.100`.
 (probably this is not a way of rebooting, it is just the page saying that rebooting is ongoing)

Analyzing the page sources I also found this queries:

- `ind.cgi?ae=` + number
- `ind.cgi?a` + number `=` + number
- `ind.cgi?d` + number `=` + number

whose purpose seems to be only to change the status of the indicators on the Control Panel web page.

I've saved in `retrieved_from_webby/` the general js file, in case looking into it turns useful for implementing some hidden funcionality (of which I doubt).

## Commanding, via SNMP

It is also possible to access 20 parameters by SNMP, which is very fast.
For that, the debian package `snmp` needs to be installed.

Examples: read Out5
```
ocs@last0:~$ snmpget -v 1 -c public 10.23.2.15 .1.3.6.1.4.1.17095.3.6.0
iso.3.6.1.4.1.17095.3.6.0 = INTEGER: 0
```
set Out5 to 1 and then to 0
```
ocs@last0:~$ snmpset -v 1 -c write 10.23.2.15 .1.3.6.1.4.1.17095.3.6.0 i 1
iso.3.6.1.4.1.17095.3.6.0.0 = INTEGER: 1
ocs@last0:~$ snmpset -v 1 -c write 10.23.2.15 .1.3.6.1.4.1.17095.3.6.0 i 0
iso.3.6.1.4.1.17095.3.6.0.0 = INTEGER: 0
```

## Matlab class and proxy settings

Presently, the class `inst.tinycontrolIPpowerSocket` uses matlab's `webread`. The API of `webread` is comparatively
simple, and inherits from the environment variables `http_proxy` and `no_proxy`.

It is important to us that queries within the observatory don't go through the WIS proxy (which may be
unreachable). To this extent, the variable `no_proxy` should contain a comma-separated list of IPs, which
includes the addresses of the switches we want to talk directly to. **Note that if the list ends with
a trailing comma** (it happened to us by mistake) matlab will hang on `webread`.

There would be another option for controlling whether the http proxy is used or not, which involves using
the more advanced `matlab.net.http` API. That has an explicit option for the proxy.
An example of it (not fully developed for our functionality) is
given in the directory `using_matlab.net.http/`. 

A third option would be to use SNMP calls, which are direct.
