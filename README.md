# LTE Modem Dashboard


New Dashboard will have a different architecture and use the following components:

Server side:
* InfluxDB v2 - Time Series Data store (has Dashboard capabilities also)
* Telegraf - Get data from MQTT and store in Influxdb
* Grafana - Dashboard for displaying the measurements

Modem side:
* Shell scripts from this project - Get data from modem and send to Telegraf
* jq - Json library
* curl - Send Json to Telegraf

![Imgur](https://i.imgur.com/nhg3e9d.jpg)


** INFORMATION BELOW IS OUTDATED. Will be updated once refactoring is completed **

** ============================================================================ **

The following will describe the method used and explain how to setup and use this utility to get a dashboard to view the modem status of an LTE modem installed on a device/system that has ModemManager. 

With little customization, it can be adopted to work without ModemManger if you have another way of getting access to the modem via AT commands. (This will not be explained as it is not the focus of this utility)

The utlity is also geared towards a system running OpenWrt/LEDE with LuCI - however it is optional.

The design was focus on not storing data on the device but on cloud storage and not having special utilities locally to graph the data. It utilizes [Google Fusion tables](https://www.dataone.org/software-tools/google-fusion-tables) to store data and Google Visualization to provide the graphs.

The other focus on the design was to use the fewest number of pieces (files) on the system. Apart from the 3rd party utility used to interact with Google Fusion tables, there are only three files required:

* **getModemData.sh** - this queries the modem via ModemManager's mmcli utility to get modem data and insert into your Google Fusion table
* **stopModemData.sh** - this is optional. It is used for LuCI custom command to stop the collection of modem data.
* **ms.html** - this is used to provide the dashboard. It queries the Google Fusion table and graphs the data. This file can actually be hosted on any system.

# Prereqs
1. If using ModemManager, start it in Debug mode
2. Have Bash shell installed

# Setup
## Fusion Table
 1. The first thing you'll want to do is get your Google Fusion table created. If you are not familiar with this, please refer to this video for reference.

[![YouTube video](http://img.youtube.com/vi/tlwoVnHvU5o/0.jpg)](https://www.youtube.com/watch?v=tlwoVnHvU5o)

 2. Create a schema with these columns: 
 
 ![Schema](https://i.imgur.com/upRWnrA.png)
 
  * All columns except DATE are of: 
  
  ![Number Columns](https://i.imgur.com/DSriWlX.png)
  
  * DATE column is: 
  
  ![Date Column](https://i.imgur.com/QjhcCE3.png)
 
 3. Make the table accessible for reading without having to use OAuth by Sharing it with `Anyone who has the link can view` rights.
 
 4. Note down your Table ID.
 
 ## Fusion Table API
 1. Now, we need a utlity to populate the Fusion Table we get from the modem. To do so, we'll use [this](https://github.com/fusiontables/fusion-tables-api-samples/tree/master/ftapi) utility. We only need to get the ftapi folder. Infomation on how to setup the credential and other access can be found in it's [README.html](https://github.com/fusiontables/fusion-tables-api-samples/blob/master/ftapi/README.html) file (which you'll want to view in a browser after downloading).
 2. You'll want to also incorporate this [PR](https://github.com/fusiontables/fusion-tables-api-samples/pull/62).
 2. Place the ftapi folder and all its content in `/root/`
 
 ## Get Modem Data
 1. Simply place the `getModemData.sh` file in `/root/ftapi/`
 2. Make it executable (if required) by issuing `chmod +x /root/ftapi/getModemData.sh`
 3. Open `getModemData.sh` and replace `<YOUR_TABLEID>` with the Table ID of your table noted down in Step 4 of the first setup section.
 4. OPTIONAL - If you want to run this everytime your system starts, put the following line in `/etc/rc.local` just before `exit 0`
 * `/root/ftapi/getModemData.sh &`
 
 ## Dashboard
 1. Place the file `ms.html` into `/www/`
 2. If required, give the file these permission `chmod 644 /www/ms.html`
 3. Open `/www/ms.html` and replace (around line 14) `<YOUR_TABLEID>` with the Table ID of your table noted down in Step 4 of the first setup section.
 
 ## OPTIONAL - Using LuCI Custom Commands to Start and Stop the collection of data.
 1. First, you'll need to put `stopModemData.sh` into `/root/ftapi/` (Can be placed in another location if so desired)
 2. Make it executable (if required) by issuing `chmod +x /root/ftapi/stopModemData.sh`
 3. Go to LuCI Custom Commands section of the modem UI, and enter these:
 * To Start: 
 
 ![Start](https://i.imgur.com/n7Hfc8x.png)
 
 * To Stop:
 
 ![Stop](https://i.imgur.com/wf45m3W.png)
 
 4. Press `RUN` on the Start script


# Access Dashboard
The dashboard can be viewed at `https://<modem hostname, dns, ip>/ms.html`

![Dashboard](https://i.imgur.com/4HmTwkX.png)

# Issues
* Google does have API limits that may come into play. I believe they are 25,000 per day and 200 every 100 seconds.

# To DOs
* Display current band
* Mobile friendly/responsive UI
* Prune table
