/*  
 *  ------ LoRaWAN Send Temperature and Humidity - 
 * Start GPS and send GPS info -------- 
 *  
 *  Explanation: This example shows how start the GPS in stand-alone 
 *  mode and it waits for GPS data is available. When the GPS data is 
 *  available sent it every 5 seconds
 * 
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           1.1 
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego 
 */

#include <WaspLoRaWAN.h>
#include <CayenneLPP.h>
#include <Wasp3G.h>

// LoRaWAN radio socket
uint8_t socket = SOCKET0;

// Device parameters for Back-End registration
////////////////////////////////////////////////////////////
// TTN Waspmote_gsp node DEUI
char DEVICE_EUI[]  = "004C1601A79842B7";
char APP_EUI[] = "70B3D57ED0010BAA";
char APP_KEY[] = "66318AE630BBD4DA506248A93BB13C4E";

// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 3;

// Define data payload to send (maximum is up to data rate)
char data[51];

// Store GPS answer and status
int8_t answer, GPS_status = 0;

// Variable to store the temperature read value
float lat;

// Variable to store the humidity read value
float lng;

float alt;

// Stores error status for LoRaWAN API
uint8_t error;

uint8_t f_cnt_ul = 0;
uint8_t f_cnt_dl = 0;

void setup() 
{
  USB.ON();
  USB.println(F("LoRaWAN - Send GPS Info - OTAA Send Unconfirmed\n"));


  USB.println(F("------------------------------------"));
  USB.println(F("Module configuration"));
  USB.println(F("------------------------------------\n"));


  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if(error == 0) {
    USB.println(F("1. Switch ON OK"));     
  } else {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 2. Factory Reset LoRaWAN module
  //////////////////////////////////////////////

  error = LoRaWAN.factoryReset();

  // Check status
  if(error == 0) {
    USB.println(F("2. Reset to factory default values OK"));     
  } else {
    USB.print(F("2. Reset to factory error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 2. Set Device EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Device EUI set OK"));     
  }
  else 
  {
    USB.print(F("2. Device EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 3. Set Application EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("3. Application EUI set OK"));     
  }
  else 
  {
    USB.print(F("3. Application EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 4. Set Application Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Application Key set OK"));     
  }
  else 
  {
    USB.print(F("4. Application Key set error = ")); 
    USB.println(error, DEC);
  }

  // set ADR
  // error = LoRaWAN.setADR("on");

  // // Check status
  // if( error == 0 ) 
  // {
  //   USB.println(F("8. Set Adaptive data rate status to on OK"));     
  // }
  // else 
  // {
  //   USB.print(F("8. Set Adaptive data rate status to on error = ")); 
  //   USB.println(error, DEC);
  // }

  // Confiure Power index
  error = LoRaWAN.setPower(5);
  if (error == 0) {
    USB.print(F("Power Index set OK"));
  } 
  else {
    USB.print(F("Power Index set error = "));
    USB.println(error, DEC);
  }

  ///////////////////////////////////////////////
  // 7. Configure Channels
  //////////////////////////////////////////////

  
  // Turn on channels 8 to 15 (AU915_CH8_CH15 frequency plan). Turn off other channels 
  
  for (int ch = 0; ch <= 7; ch++) {
    error = LoRaWAN.setChannelStatus(ch, "off");

    // Check status
    if( error == 0 )
    {
      USB.println(F("7. Channel status set OK")); 
    }
    else
    {
      USB.print(F("7. Channel status set error = ")); 
      USB.println(error, DEC);
    }
  }

  // Enable second sub-band of AU915: 916.8 - 918.2MHz
  for (int ch = 8; ch <= 15; ch++) {
    error = LoRaWAN.setChannelStatus(ch, "on");

    // Check status
    if( error == 0 )
    {
      USB.println(F("7. Channel status set OK")); 
    }
    else
    {
      USB.print(F("7. Channel status set error = ")); 
      USB.println(error, DEC);
    }
  }
  
  for (int ch = 16; ch <= 63; ch++) {
    error = LoRaWAN.setChannelStatus(ch, "off");

    // Check status
    if( error == 0 )
    {
      USB.println(F("7. Channel status set OK")); 
    }
    else
    {
      USB.print(F("7. Channel status set error = ")); 
      USB.println(error, DEC);
    }
  }

  // Enable Downlink sub-band
  for (int ch = 64; ch <= 71; ch++) {
    error = LoRaWAN.setChannelStatus(ch, "on");

    // Check status
    if( error == 0 )
    {
      USB.println(F("7. Channel status set OK")); 
    }
    else
    {
      USB.print(F("7. Channel status set error = ")); 
      USB.println(error, DEC);
    }
  }


  //////////////////////////////////////////////
  // 9. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) {
    USB.println(F("9. Save configuration OK"));     
  } else {
    USB.print(F("9. Save configuration error = ")); 
    USB.println(error, DEC);
  }

  USB.println(F("\n------------------------------------"));
  USB.println(F("LoRaWAN Module configured!"));
  USB.println(F("------------------------------------\n"));

  LoRaWAN.getDeviceEUI();
  USB.print(F("Device EUI: "));
  USB.println(LoRaWAN._devEUI);  

  LoRaWAN.getDeviceAddr();
  USB.print(F("Device Address: "));
  USB.println(LoRaWAN._devAddr);

  LoRaWAN.getPower();
  USB.print(F("LoRaWAN Power Index = "));
  USB.println(LoRaWAN._powerIndex, DEC);  


  for( int i = 0; i < 72; i++)
  {
    LoRaWAN.getChannelFreq(i);
    LoRaWAN.getChannelDRRange(i);
    LoRaWAN.getChannelStatus(i);

    USB.print(F("Channel: "));
    USB.println(i);
    USB.print(F("  Freq: "));
    USB.println(LoRaWAN._freq[i]);
    USB.print(F("  DR min: "));
    USB.println(LoRaWAN._drrMin[i], DEC);
    USB.print(F("  DR max: "));
    USB.println(LoRaWAN._drrMax[i], DEC);
    USB.print(F("  Status: "));
    if (LoRaWAN._status[i] == 1)
    {
      USB.println(F("on"));
    }
    else
    {
      USB.println(F("off"));
    }
    USB.println(F("----------------------------"));
  }

  USB.println();

  // Activates the 3G module:
  answer = _3G.ON();
  if ((answer == 1) || (answer == -3))
  {
    USB.println(F("3G module ready..."));

    // 2. starts the GPS in MS-based mode:
    USB.println(F("Starting in stand-alone mode")); 
    GPS_status = _3G.startGPS();
    if (GPS_status == 1)
    { 
        USB.println(F("GPS started"));
    }
    else
    {
        USB.println(F("GPS NOT started"));   
    }
  }
  else
  {
      // Problem with the communication with the 3G module
      USB.println(F("3G module not started")); 
  }

}

void loop() 
{

  //////////////////////////////////////////////
  // 3. Send unconfirmed packet 
  //////////////////////////////////////////////

  USB.println(F("Retrieving GPS data..."));

  if (GPS_status == 1)
  {
    // Gets GPS info
    answer = _3G.getGPSinfo();
    if (answer == 1)
    {
        Utils.blinkGreenLED(200, 5);

        lat = _3G.convert2Degrees(_3G.latitude);
        lng = _3G.convert2Degrees(_3G.longitude);
        alt = atof(_3G.altitude);        
        // when it's available, shows it
        USB.print(F("Latitude (in degrees): "));
        USB.println(lat);
        USB.print(F("Longitude (in degrees): "));
        USB.println(lng);
        USB.print(F("Date: "));
        USB.println(_3G.date);
        USB.print(F("UTC_time: "));
        USB.println(_3G.UTC_time);
        USB.print(F("Altitude: "));
        USB.println(alt);
        USB.print(F("SpeedOG: "));
        USB.println(_3G.speedOG);
        USB.print(F("Course: "));
        USB.println(_3G.course);
        USB.println(F(""));
    }
    else
    {
        USB.println(F("Data not available...."));
        Utils.blinkRedLED(500, 5);  
    }
  }
  else
  {
      USB.print(F("GPS not started"));
      Utils.blinkRedLED(200, 3);  
      delay(58000);      
  }

  delay(2000);

  if (GPS_status == 1 && answer == 1) {

    //////////////////////////////////////////////
    // 1. Switch on
    //////////////////////////////////////////////

    error = LoRaWAN.ON(socket);

    // Check status
    if(error == 0) {
      USB.println(F("1. Switch ON OK"));     
    } else {
      USB.print(F("1. Switch ON error = ")); 
      USB.println(error, DEC);
    }

    //////////////////////////////////////////////
    // 2. Join network
    //////////////////////////////////////////////

    error = LoRaWAN.joinOTAA();

    // Check status
    if(error == 0) {

      USB.println(F("2. Join network OK"));

      CayenneLPP lpp(51);

      lpp.reset();
      lpp.addGPS(3, lat, lng, alt);
      Utils.hex2str(lpp.getBuffer(), data, lpp.getSize());
      USB.println(data);

      LoRaWAN.setUpCounter(f_cnt_ul);
      LoRaWAN.setDownCounter(f_cnt_dl);

      error = LoRaWAN.sendUnconfirmed(PORT, data);

      // Error messages:
      /*
       * '6' : Module hasn't joined a network
       * '5' : Sending error
       * '4' : Error with data length    
       * '2' : Module didn't response
       * '1' : Module communication error   
       */
      // Check status
      if(error == 0) {
        USB.println(F("3. Send Unconfirmed packet OK")); 
        f_cnt_ul++;
        if (LoRaWAN._dataReceived == true)
        {
          f_cnt_dl++; 
          USB.print(F("   There's data on port number "));
          USB.print(LoRaWAN._port,DEC);
          USB.print(F(".\r\n   Data: "));
          USB.println(LoRaWAN._data);
        }
      } else {
        USB.print(F("3. Send Unconfirmed packet error = ")); 
        USB.println(error, DEC);
      }
    } else {
      USB.print(F("2. Join network error = ")); 
      USB.println(error, DEC);
    }

    LoRaWAN.getUpCounter();
    LoRaWAN.getDownCounter();
    USB.print("Up Counter is:");
    USB.println(LoRaWAN._upCounter, DEC);
    USB.print("Down Counter is:");
    USB.println(LoRaWAN._downCounter ,DEC);


    //////////////////////////////////////////////
    // 4. Switch off
    //////////////////////////////////////////////

    error = LoRaWAN.OFF(socket);

    // Check status
    if(error == 0) {
      USB.println(F("4. Switch OFF OK"));     
    } else {
      USB.print(F("4. Switch OFF error = ")); 
      USB.println(error, DEC);
    }

    USB.println();
    delay(8000);
  }

}





