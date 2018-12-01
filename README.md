# LTE-Modem-Dashboard
The following will describe the method used and explain how to setup and use this utility to get a dashboard to view the modem status of an LTE modem installed on a device/system that has ModemManager. 

With little customization, it can be adopted to work without ModemManger if you have another way of getting access to the modem via AT commands. (This will not be explained as it is not the focus of this utility)

The utlity is also geared towards a system running OpenWrt/LEDE with LuCI - however it is optional.

The design was focus on not storing data on the device but on cloud storage and not having special utilities locally to graph the data. It utilizes Google Fusion tables to store data and Google Visulization to provide the graphs.

The other focus on the design was to use the fewest number of pieces (files) on the system. Apart from the 3rd party utility used to interact with Google Fusion tables, there are only three files required.

* getModemData.sh - this queries the modem via ModemManager's mmcli utility to get modem data and insert into your Google Fusion table
* stopModemData.sh - this is optional. It is used for LuCI custom command to stop the collection of modem data.
* ms.html - this is used to provide the dashboard. It queries the Google Fusion table and graphs the data



