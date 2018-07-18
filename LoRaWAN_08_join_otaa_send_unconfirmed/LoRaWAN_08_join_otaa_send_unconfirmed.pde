/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the module and
 *  send packets to a LoRaWAN gateway without ACK after join a network
 *  using OTAA
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.2
 *  Design:            David Gascon 
 *  Implementation:    Luis Miguel Marti
 */

#include <WaspLoRaWAN.h>

// socket to use
//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// Device parameters for Back-End registration
////////////////////////////////////////////////////////////
// TTN Waspmote_gsp node DEUI
char DEVICE_EUI[]  = "0036112241EA99C3";
char APP_EUI[] = "70B3D57ED0010448";
char APP_KEY[] = "8B6CD7D08A030B8F0B1CD73A2C28F472";
////////////////////////////////////////////////////////////

// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 3;

// Define data payload to send (maximum is up to data rate)
char data[] = "010203040506";

// variable
uint8_t error;

uint8_t f_cnt_ul = 0;
uint8_t f_cnt_dl = 0;

void setup() 
{
  USB.ON();
  USB.println(F("LoRaWAN example - Send Unconfirmed packets (no ACK)\n"));


  USB.println(F("------------------------------------"));
  USB.println(F("Module configuration"));
  USB.println(F("------------------------------------\n"));


  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
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
  
  for (int ch = 16; ch <= 64; ch++) {
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

  //////////////////////////////////////////////
  // 5. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("5. Save configuration OK"));     
  }
  else 
  {
    USB.print(F("5. Save configuration error = ")); 
    USB.println(error, DEC);
  }


  USB.println(F("\n------------------------------------"));
  USB.println(F("Module configured"));
  USB.println(F("------------------------------------\n"));

  LoRaWAN.getDeviceEUI();
  USB.print(F("Device EUI: "));
  USB.println(LoRaWAN._devEUI);  

  LoRaWAN.getAppEUI();
  USB.print(F("Application EUI: "));
  USB.println(LoRaWAN._appEUI);  

  USB.println();  
}



void loop() 
{

  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 2. Join network
  //////////////////////////////////////////////

  error = LoRaWAN.joinOTAA();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Join network OK")); 

    //////////////////////////////////////////////
    // 3. Send unconfirmed packet 
    //////////////////////////////////////////////
    LoRaWAN.setUpCounter(f_cnt_ul);
    LoRaWAN.setDownCounter(f_cnt_dl);

    error = LoRaWAN.sendUnconfirmed( PORT, data);

    // Error messages:
    /*
     * '6' : Module hasn't joined a network
     * '5' : Sending error
     * '4' : Error with data length	  
     * '2' : Module didn't response
     * '1' : Module communication error   
     */
    // Check status
    if( error == 0 ) 
    {
      USB.println(F("3. Send unconfirmed packet OK"));   
      f_cnt_ul++;  
      if (LoRaWAN._dataReceived == true)
      { 
        f_cnt_dl++;
        USB.print(F("   There's data on port number "));
        USB.print(LoRaWAN._port,DEC);
        USB.print(F(".\r\n   Data: "));
        USB.println(LoRaWAN._data);
      }
    }
    else 
    {
      USB.print(F("3. Send unconfirmed packet error = ")); 
      USB.println(error, DEC);
    }

    LoRaWAN.getUpCounter();
    LoRaWAN.getDownCounter();
    USB.print("Up Counter is:");
    USB.println(LoRaWAN._upCounter,DEC);
    USB.print("Down Counter is:");
    USB.println(LoRaWAN._downCounter ,DEC);    
  }
  else 
  {
    USB.print(F("2. Join network error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 4. Switch off
  //////////////////////////////////////////////
  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("4. Switch OFF error = ")); 
    USB.println(error, DEC);
  }


  USB.println();
  delay(30000);



}




