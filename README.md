# Apple Watch Documentation

## Teo Hildebrand

## March 2020

## 1 Apple watch app

## Post Data

Send current heart rate to connected iPhone device. App must be also running
on iPhone in order to transfer data

## Gather Data

Use to collect current heart rate from user. App will ask for permission to gather
health data and to store the date on the device.


## 2 iPhone app

### User Input

User-ID

Enter the User-ID obtained from dashboard. If invalid user-ID is entered, the
API will return error code 100

Device-ID

Enter Device-ID generated from dashboard. If invalid device-ID is entered, the
API will return error code 304. If device-ID from another user is entered API
will return 303.

Server

Enter server to send API-calls to

API-key

Enter API-Key generated from dashboard. If invalid API-key is entered, the
API will return error code 100


### Start/Stop activity

Push to start activity. API will return an activity-ID greater than zero. By de-
fault the apps Activity-ID is set to zero. ”Start Activity” will set apps activity-
ID returned from API. If API returns any error codes activity will not be started
and error code will be displayed.
Stop activity sends request to API-server to stop. API-server returns with
Activity-ID zero and app sets the Activity-ID to zero

### Check activity

Check if there is any activity running. If API returns an activity-id greater than
zero then activity is currently running. If API returns with activity-id equal to
zero then no activity is currently running.

### Send Data

Sends current heart rate to the server. If no activity is running or no heart rate
has been transferred to the phone no data can be sent to the server.
If heart rate has been transferred and activity is currently running then data
will be posted successfully to the API server.

### Display Heart Rate

Displays the current heart rate



### Video Documentation 
https://www.youtube.com/watch?v=9PG2pLskhgA
