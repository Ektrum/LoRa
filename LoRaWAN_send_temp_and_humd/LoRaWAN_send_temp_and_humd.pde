/*  
 *  ------ LoRaWAN Send Temperature and Humidity -------- 
 * This program sends temperature and humidity telemetry from Agriculture Board V2.0
 * using LoRaWAN ABP send Unconfirmed packets.
 * Author: Bruno Faria
 * Date: 29th Jun 2018
 */

#include <WaspLoRaWAN.h>
#include <WaspSensorAgr_v20.h>

// LoRaWAN radio socket
uint8_t socket = SOCKET0;

// Device parameters for Back-End registration
// Device parameters for waspmote_02
char DEVICE_EUI[]  = "00A093869A786341";
char DEVICE_ADDR[] = "26031EAA";
char NWK_SESSION_KEY[] = "2358C553CCCDA064448010321D6ECBC9";
char APP_SESSION_KEY[] = "57C5A1CB45F5159B12C475E59EFB9A16";

// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 3;

// Define data payload to send (maximum is up to data rate)
char data[51];

// Variable to store the temperature read value
float temperature;

// Variable to store the humidity read value
float humidity;

// Stores error status for LoRaWAN API
uint8_t error;

void setup() 
{
  USB.ON();
  USB.println(F("LoRaWAN - Send temperature and humidity - ABP Send Unconfirmed\n"));


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
  // 3. Set Device EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( error == 0 ) {
    USB.println(F("3. Device EUI set OK"));     
  } else {
    USB.print(F("3. Device EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 4. Set Device Address
  //////////////////////////////////////////////

  error = LoRaWAN.setDeviceAddr(DEVICE_ADDR);

  // Check status
  if(error == 0) {
    USB.println(F("4. Device address set OK"));     
  } else {
    USB.print(F("4. Device address set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 5. Set Network Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setNwkSessionKey(NWK_SESSION_KEY);

  // Check status
  if(error == 0) {
    USB.println(F("5. Network Session Key set OK"));     
  } else {
    USB.print(F("5. Network Session Key set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 6. Set Application Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setAppSessionKey(APP_SESSION_KEY);

  // Check status
  if(error == 0) {
    USB.println(F("6. Application Session Key set OK"));     
  } else {
    USB.print(F("6. Application Session Key set error = ")); 
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
  // 8. Set Adaptive Data Rate
  //////////////////////////////////////////////

  // set ADR
  error = LoRaWAN.setADR("on");

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("8. Set Adaptive data rate status to on OK"));     
  }
  else 
  {
    USB.print(F("8. Set Adaptive data rate status to on error = ")); 
    USB.println(error, DEC);
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

  USB.println();

  USB.println(F("\n------------------------------------"));
  USB.println(F("LoRaWAN Channel Configuration:"));
  USB.println(F("------------------------------------\n"));  

  USB.println(F("\n----------------------------"));

  for(int i=0; i<64; i++) {
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
    if (LoRaWAN._status[i] == 1) {
      USB.println(F("on"));
    } else {
      USB.println(F("off"));
    }
    USB.println(F("----------------------------"));
  }

  // Turn on the agriculture sensor board
  SensorAgrv20.ON();

  // Turn on the RTC
  RTC.ON();
  
}

void loop() 
{

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

  error = LoRaWAN.joinABP();

  // Check status
  if(error == 0) {
    USB.println(F("2. Join network OK"));   

    //////////////////////////////////////////////
    // 3. Send unconfirmed packet 
    //////////////////////////////////////////////

    USB.println(F("Retrieving sensor data..."));

    // Turn on the sensor and wait for stabilization and response time
    SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_TEMPERATURE);
    delay(100);

    SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_HUMIDITY);
    delay(15000);

    // Read the humidity and temperature from the sensor 
    temperature = SensorAgrv20.readValue(SENS_AGR_TEMPERATURE);
    humidity = SensorAgrv20.readValue(SENS_AGR_HUMIDITY);
  
    // Turn off the sensor
    SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_TEMPERATURE);
    SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_HUMIDITY);

    // Print sensor values
    USB.print(F("\nTemperature: "));
    USB.println(temperature);
    USB.print(F("\nHumidity: "));
    USB.println(humidity);

    // Need to send values in hexadecimal. Convert floats to fixed point with two decimal places
    uint16_t i_temp = (uint16_t) (temperature * 100);
    uint16_t i_humd = (uint16_t) (humidity * 100);

    // Convert values to hex string and concatenate in data message buffer
    itoa(i_temp, data, 16);
    itoa(i_humd, &data[strlen(data)], 16);

    USB.println(F("3. Sending Unconfirmed packet..."));

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
      if (LoRaWAN._dataReceived == true)
      { 
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
  delay(60000);

}




