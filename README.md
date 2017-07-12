# pigpiod-tcl TCL package version 0.1

TCL wrapper for pigpiod interface to access Raspberry PI GPIO, SPI, I2C, PWM, GPIO callbacks and more.
You can download the latest pigpio library from  http://abyz.co.uk/rpi/pigpio/download.html

# Installation
Make sure you enable I2C and SPI before using this package. Type *sudo raspi-config* navigate to
**Advanced otpions** and enabled I2C and SPI buses.
To build and install run the following commands in your terminal on your raspberry pi. 


```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install tcl
sudo apt-get install tcl-dev
sudo apt-get install swig

git clone https://github.com/danielsulik/pigpiod-tcl.git
cd pigpiod-tcl
unzip pigpio.zip
cd PIGPIO
make -j4
sudo make install
sudo ./build
sudo pigpiod
```

For more details on pigpio daemon please refer to docs in http://abyz.co.uk/rpi/pigpio/download.html

## Supported pigpiod TCL procedures:

### CONNECT/DISCONNECT TO PIGPIO DAEMON
### pigpio_start    *address port*

   Connect to pigpiod daemon listening at *address* and *port*
  
   Parameter | Description
   --- | --- 
   *address* | Specifies the host or IP address of the Pi running the pigpio daemon. It may be 0 or literary localhost in     which case localhost is used unless overridden by the PIGPIO_ADDR environment variable.` 
   *port* | Specifies the port address used by the Pi running the pigpio daemon.  It may be 0 in which case "8888" is used    unless overridden by the PIGPIO_PORT environment variable.
   returns | Returns an integer handle greater than or equal to zero if OK. This handle is passed to procedures to specify    the Pi to be operated on. 

### pigpio_stop     *pi*

   Terminates the connection to a pigpio daemon and releases resources used by the library. 
   
   Parameter | Description
   --- | --- 
   *pi*| Handle returned by *`pigpio_start`*
   returns| None

# MISC
### get_current_tick      *pi*

   Gets the current system tick. Tick is the number of microseconds since system boot. As tick is an *unsigned 32*  bit       quantity it wraps around after 2**32 microseconds, which is approximately 1 hour 12 minutes.
   
   Parameter | Description
   --- | --- 
   *pi*| Handle returned by *`pigpio_start`*
   returns| None
   
### get_hardware_revision *pi*
Get the Pi's hardware revision number. The hardware revision is the last few characters on the **Revision** line of */proc/cpuinfo*. If the hardware revision can not be found or is not a valid hexadecimal number the function returns 0. The revision number can be used to determine the assignment of GPIO to pins.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
    
### get_pigpio_version    *pi*
Returns the pigpio version. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| Returns the pigpio version number.

### pigpiod_if_version 
Return the pigpiod interface version.
Returns the pigpio version. 

Parameter | Description
--- | --- 
None| 
returns| Returns the pigpio interface version number.

### pigpio_error *errnum*
Return a text description for an error code. 

Parameter | Description
--- | --- 
*errnum*| Error code  
returns| Error text description.

### set_watchdog          *pi gpio timeout*
Sets a watchdog for a GPIO.  Returns 0 if OK, otherwise PI_BAD_USER_GPIO or PI_BAD_WDOG_TIMEOUT. The watchdog is nominally in milliseconds. Only one watchdog may be registered per GPIO. The watchdog may be cancelled by setting timeout to 0. If no level change has been detected for the GPIO for timeout milliseconds any notification for the GPIO has a report written to the fifo with the flags set to indicate a watchdog timeout. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| Broadcom numbered GPIO (0-31)
*timeout*| A GPIO watchdog timeout in milliseconds. Range 0 - 60000
returns| Returns zero if OK, otherwise PI_BAD_USER_GPIO or PI_BAD_WDOG_TIMEOUT. 
   
### set_glitch_filter    *pi gpio steady*
Sets a glitch filter on a GPIO. Level changes on the GPIO are not reported unless the level has been stable for at least steady microseconds. The level is then reported. Level changes of less than steady microseconds are ignored. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| Broadcom numbered GPIO (0-31)
*steady*| 0-300000 microseconds
returns| Returns zero if OK, otherwise PI_BAD_USER_GPIO, or PI_BAD_FILTER.

### set_noise_filter     *pi gpio steady active*
Sets a noise filter on a GPIO. Level changes on the GPIO are ignored until a level which has been stable for steady microseconds is detected. Level changes on the GPIO are then reported for active microseconds after which the process repeats. 
`Note, level changes before and after the active period may be reported. Your software must be designed to cope with such reports.`

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| Broadcom numbered GPIO (0-31)
*steady*| 0-300000 microseconds
*active*| 0-1000000 microseconds
returns| Returns zero if OK, otherwise PI_BAD_USER_GPIO, or PI_BAD_FILTER.

# GPIO
### set_mode            *pi gpio mode*
Set the GPIO mode. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-53
*mode*| PI_INPUT, PI_OUTPUT, PI_ALT0, PI_ALT1, PI_ALT2, PI_ALT3, PI_ALT4, PI_ALT5
returns| Returns zero if OK, otherwise PI_BAD_GPIO, PI_BAD_MODE, or PI_NOT_PERMITTED.

### get_mode            *pi gpio*
Get the GPIO mode.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-53
returns|Returns the GPIO mode (PI_INPUT, PI_OUTPUT, PI_ALT0, PI_ALT1, PI_ALT2, PI_ALT3, PI_ALT4, PI_ALT5) if OK, otherwise PI_BAD_GPIO. 

### set_pull_up_down    *pi gpio pud*
Set or clear the GPIO pull-up/down resistor.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-53
*pud*| PI_PUD_UP, PI_PUD_DOWN, PI_PUD_OFF
returns| Returns zero if OK, otherwise PI_BAD_GPIO, PI_BAD_PUD, or PI_NOT_PERMITTED.

### gpio_read           *pi gpio*
Read the GPIO level.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-53
returns| Returns GPIO level if OK, otherwise PI_BAD_GPIO.

### gpio_write          *pi gpio level*
Write the GPIO level.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-53
*level*| 0, 1
returns| Returns 0 if OK, otherwise PI_BAD_GPIO, PI_BAD_LEVEL, or PI_NOT_PERMITTED. 
`If PWM or servo pulses are active on the GPIO they are switched off.`

### get_pad_strength    *pi pad*
This function returns the pad drive strength in mA.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*pad*| 0-2, the pad to get
returns| Returns the pad drive strength if OK, otherwise PI_BAD_PAD. 

Pad |	GPIO
---|---
0 | 0-27
1 | 28-45
2 | 46-53

### set_pad_strength    *pi pad padStrength*
This function sets the pad drive strength in mA.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*pad*| 0-2, the pad to set
*padStrength*| 1-16 mA
returns| Returns zero if OK, otherwise PI_BAD_PAD, or PI_BAD_STRENGTH. 

### read_bank_1         *pi*
Read the levels of the bank 1 GPIO (GPIO 0-31).  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| The returned 32 bit integer has a bit set if the corresponding GPIO is logic 1. GPIO n has bit value (1<<n).

### read_bank_2         *pi*
Read the levels of the bank 2 GPIO (GPIO 32-53).  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| The returned 32 bit integer has a bit set if the corresponding GPIO is logic 1. GPIO n has bit value (1<<(n-32)).

### clear_bank_1        *pi bits*
Clears GPIO 0-31 if the corresponding bit in bits is set. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*bits*|a bit mask with 1 set if the corresponding GPIO is to be cleared.
returns| Returns zero if OK, otherwise PI_SOME_PERMITTED. A status of PI_SOME_PERMITTED indicates that the user is not allowed to write to one or more of the GPIO.

### clear_bank_2        *pi bits*
Clears GPIO 32-53 if the corresponding bit (0-21) in bits is set.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*bits*|a bit mask with 1 set if the corresponding GPIO is to be cleared.
returns| Returns zero if OK, otherwise PI_SOME_PERMITTED. A status of PI_SOME_PERMITTED indicates that the user is not allowed to write to one or more of the GPIO.

### set_bank_1          *pi bits*
Sets GPIO 0-31 if the corresponding bit in bits is set.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*bits*|a bit mask with 1 set if the corresponding GPIO is to be cleared.
returns| Returns zero if OK, otherwise PI_SOME_PERMITTED. A status of PI_SOME_PERMITTED indicates that the user is not allowed to write to one or more of the GPIO. 

### set_bank_2          *pi bits*
Sets GPIO 32-53 if the corresponding bit (0-21) in bits is set. .  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*bits*|a bit mask with 1 set if the corresponding GPIO is to be cleared.
returns| Returns zero if OK, otherwise PI_SOME_PERMITTED. A status of PI_SOME_PERMITTED indicates that the user is not allowed to write to one or more of the GPIO. 

### hardware_clock      *pi gpio clkfreq*
Starts a hardware clock on a GPIO at the specified frequency. Frequencies above 30MHz are unlikely to work. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| See description below
*frequency*|0 (off) or 4689-250000000 (250M)
returns|Returns zero if OK, otherwise PI_NOT_PERMITTED, PI_BAD_GPIO, PI_NOT_HCLK_GPIO, PI_BAD_HCLK_FREQ,or PI_BAD_HCLK_PASS. The same clock is available on multiple GPIO. The latest frequency setting will be used by all GPIO which share a clock. 
The GPIO must be one of the following. 
GPIO| clock | Model
---|---|---
4  | clock 0 | All models
5  | clock 1 | All models but A and B (reserved for system use)
6  | clock 2 | All models but A and B
20 | clock 0 | All models but A and B
21 | clock 1 | All models but A and Rev.2 B (reserved for system use)
32 | clock 0 | Compute module only
34 | clock 0 | Compute module only
42 | clock 1 | Compute module only (reserved for system use)
43 | clock 2 | Compute module only
44 | clock 1 | Compute module only (reserved for system use)

Access to clock 1 is protected by a password as its use will likely crash the Pi. The password is given by or'ing 0x5A000000 with the GPIO number.

### hardware_PWM        *pi gpio PWMfreq PWMduty*
Starts hardware PWM on a GPIO at the specified frequency and dutycycle. Frequencies above 30MHz are unlikely to work. 
+ `NOTE: Any waveform started by wave_send_* or wave_chain will be cancelled. This function is only valid if the pigpio main clock is PCM. The main clock defaults to PCM but may be overridden when the pigpio daemon is started (option -t).`

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
PWMfreq | 0 (off) or 1-125000000 (125M)
PWMduty | 0 (off) to 1000000 (1M)(fully on)returns| None
retrns| Returns 0 if OK, otherwise PI_NOT_PERMITTED, PI_BAD_GPIO, PI_NOT_HPWM_GPIO, PI_BAD_HPWM_DUTY, PI_BAD_HPWM_FREQ, or PI_HPWM_ILLEGAL. 

The same PWM channel is available on multiple GPIO. The latest frequency and dutycycle setting will be used by all GPIO which share a PWM channel. The GPIO must be one of the following. 
GPIO | PWM channel | Model
---|---|---
12 | PWM channel 0 | All models but A and B
13 | PWM channel 1 | All models but A and B
18 | PWM channel 0 | All models
19 | PWM channel 1 | All models but A and B
40 | PWM channel 0 | Compute module only
41 | PWM channel 1 | Compute module only
45 | PWM channel 1 | Compute module only
52 | PWM channel 0 | Compute module only
53 | PWM channel 1 | Compute module only

The actual number of steps beween off and fully on is the integral part of 250 million divided by PWMfreq. The actual frequency set is 250 million / steps. There will only be a million steps for a PWMfreq of 250. Lower frequencies will have more steps and higher frequencies will have fewer steps. PWMduty is automatically scaled to take this into account.

# PWM
### set_PWM_dutycycle    *pi gpio dutycycle*
Start (non-zero dutycycle) or stop (0) PWM pulses on the GPIO. The set_PWM_range function may be used to change the default range of 255.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
*dutycycle*| 0-range (range defaults to 255).
returns| Returns 0 if OK, otherwise PI_BAD_USER_GPIO, PI_BAD_DUTYCYCLE, or PI_NOT_PERMITTED.  

### get_PWM_dutycycle    *pi gpio*
Return the PWM dutycycle in use on a GPIO.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
returns| Returns 0 if OK, otherwise PI_BAD_USER_GPIO or PI_NOT_PWM_GPIO. 
For normal PWM the dutycycle will be out of the defined range for the GPIO (see get_PWM_range). 
If a hardware clock is active on the GPIO the reported dutycycle will be 500000 (500k) out of 1000000 (1M). 
If hardware PWM is active on the GPIO the reported dutycycle will be out of a 1000000 (1M). 

### set_PWM_range        *pi gpio range*
Set the range of PWM values to be used on the GPIO. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
*range*| 25-40000
returns| Returns 0 if OK, otherwise PI_BAD_USER_GPIO, PI_BAD_DUTYRANGE, or PI_NOT_PERMITTED. 
`Notes: If PWM is currently active on the GPIO its dutycycle will be scaled to reflect the new range. The real range, the number of steps between fully off and fully on for each of the 18 available GPIO frequencies is   25(#1),    50(#2),   100(#3),   125(#4),    200(#5),    250(#6), 400(#7),   500(#8),   625(#9),   800(#10),  1000(#11),  1250(#12),2000(#13), 2500(#14), 4000(#15), 5000(#16), 10000(#17), 20000(#18)`

The real value set by set_PWM_range is (dutycycle * real range) / range

### get_PWM_range        *pi gpio*
Get the range of PWM values being used on the GPIO. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
returns| Returns the dutycycle range used for the GPIO if OK, otherwise PI_BAD_USER_GPIO. If a hardware clock or hardware PWM is active on the GPIO the reported range will be 1000000 (1M).

### get_PWM_real_range   *pi gpio*
Get the real underlying range of PWM values being used on the GPIO.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
returns| Returns the real range used for the GPIO if OK, otherwise PI_BAD_USER_GPIO. If a hardware clock is active on the GPIO the reported real range will be 1000000 (1M). If hardware PWM is active on the GPIO the reported real range will be approximately 250M divided by the set PWM frequency.

### set_PWM_frequency    *pi gpio frequency*
Set the frequency (in Hz) of the PWM to be used on the GPIO. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
*frequency*| >=0 Hz
returns| Returns the numerically closest frequency if OK, otherwise PI_BAD_USER_GPIO or PI_NOT_PERMITTED. If PWM is currently active on the GPIO it will be switched off and then back on at the new frequency. Each GPIO can be independently set to one of 18 different PWM frequencies. The selectable frequencies depend upon the sample rate which may be 1, 2, 4, 5, 8, or 10 microseconds (default 5). The sample rate is set when the pigpio daemon is started. 

The frequencies for each sample rate are: 
 Sample rate (us) |   Hertz
---|---
       1: 40000 20000 10000 8000 5000 4000 2500 2000 1600
           1250  1000   800  500  400  250  200  100   50

       2: 20000 10000  5000 4000 2500 2000 1250 1000  800
            625   500   400  250  200  125  100   50   25

       4: 10000  5000  2500 2000 1250 1000  625  500  400
            313   250   200  125  100   63   50   25   13
                       sample rate (us)
       5:  8000  4000  2000 1600 1000  800  500  400  320
            250   200   160  100   80   50   40   20   10

       8:  5000  2500  1250 1000  625  500  313  250  200
            156   125   100   63   50   31   25   13    6

      10:  4000  2000  1000  800  500  400  250  200  160
            125   100    80   50   40   25   20   10    5

### get_PWM_frequency    *pi gpio*
Get the frequency of PWM being used on the GPIO.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
returns| Returns the frequency (in hertz) used for the GPIO if OK, otherwise PI_BAD_USER_GPIO.

For normal PWM the frequency will be that defined for the GPIO by set_PWM_frequency. If a hardware clock is active on the GPIO the reported frequency will be that set by hardware_clock. If hardware PWM is active on the GPIO the reported frequency will be that set by hardware_PWM. 

# SERVO
### set_servo_pulsewidth *pi gpio pulsewidth*
Start (500-2500) or stop (0) servo pulses on the GPIO.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
pulsewidth | 0 (off), 500 (anti-clockwise) - 2500 (clockwise).
returns| Returns 0 if OK, otherwise PI_BAD_USER_GPIO, PI_BAD_PULSEWIDTH or PI_NOT_PERMITTED. 

The selected pulsewidth will continue to be transmitted until changed by a subsequent call to set_servo_pulsewidth. The pulsewidths supported by servos varies and should probably be determined by experiment. A value of 1500 should always be safe and represents the mid-point of rotation. You can DAMAGE a servo if you command it to move beyond its limits. 
OTHER UPDATE RATES: 
This function updates servos at 50Hz. If you wish to use a different update frequency you will have to use the PWM functions. 
Update Rate (Hz)     50   100  200  400  500
1E6/Hz            20000 10000 5000 2500 2000

Firstly set the desired PWM frequency using set_PWM_frequency. Then set the PWM range using set_PWM_range to 1E6/Hz. Doing this allows you to use units of microseconds when setting the servo pulsewidth. E.g. If you want to update a servo connected to GPIO 25 at 400Hz 
 + set_PWM_frequency(25, 400);
 + set_PWM_range(25, 2500);

Thereafter use the set_PWM_dutycycle function to move the servo, e.g. set_PWM_dutycycle(25, 1500) will set a 1500 us pulse.

### get_servo_pulsewidth *pi gpio*
Return the servo pulsewidth in use on a GPIO. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
returns| Returns 0 if OK, otherwise PI_BAD_USER_GPIO or PI_NOT_SERVO_GPIO.

# NOTIFY
### notify_open          *pi*
Get a free notification handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| Returns a handle greater than or equal to zero if OK, otherwise PI_NO_HANDLE.

A notification is a method for being notified of GPIO state changes via a pipe. Pipes are only accessible from the local machine so this function serves no purpose if you are using the library from a remote machine. The in-built (socket) notifications provided by callback should be used instead. Notifications for handle x will be available at the pipe named /dev/pigpiox (where x is the handle number). E.g. if the function returns 15 then the notifications must be read from /dev/pigpio15.

### notify_begin         *pi handle bits*
Start notifications on a previously opened handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| 0-31 (as returned by *`notify_open`*)
*bits*| Ha mask indicating the GPIO to be notified.
returns| Returns 0 if OK, otherwise PI_BAD_HANDLE. 

Each notification occupies 12 bytes in the fifo as follows: 

```C
typedef struct
{
   uint16_t seqno;
   uint16_t flags;
   uint32_t tick;
   uint32_t level;
} gpioReport_t;
```

Parameter | Description
---|---
seqno | starts at 0 each time the handle is opened and then increments by one for each report. 
flags | two flags are defined, PI_NTFY_FLAGS_WDOG and PI_NTFY_FLAGS_ALIVE. If bit 5 is set (PI_NTFY_FLAGS_WDOG) then bits 0-4 of the flags indicate a GPIO which has had a watchdog timeout. If bit 6 is set (PI_NTFY_FLAGS_ALIVE) this indicates a keep alive signal on the pipe/socket and is sent once a minute in the absence of other notification activity.
tick | the number of microseconds since system boot. It wraps around after 1h 12m. 
level | indicates the level of each GPIO. If bit 1<<x is set then GPIO x is high.

### notify_pause         *pi handle*
Pause notifications on a previously opened handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| Handle (as returned by *`notify_open`*)
returns| Returns 0 if OK, otherwise PI_BAD_HANDLE. 

Notifications for the handle are suspended until notify_begin is called again.

### notify_close         *pi handle*
Stop notifications on a previously opened handle and release the handle for reuse.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| Handle (as returned by *`notify_open`*)
returns| Returns zero if OK, otherwise PI_BAD_HANDLE.

# BIT-BANG SERIAL
### bb_serial_read_open  *pi gpio baud data_bits*
  This function opens a GPIO for bit bang reading of serial data.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31
*baud*| 50-250000
*data_bits| data_bits: 1-32
returns| Returns 0 if OK, otherwise PI_BAD_USER_GPIO, PI_BAD_WAVE_BAUD, or PI_GPIO_IN_USE. 
The serial data is returned in a cyclic buffer and is read using bb_serial_read. 
It is the caller`s responsibility to read data from the cyclic buffer in a timely fashion.

### bb_serial_read       *pi gpio bufSize*
  This proc returns bytes of data read from the bit bang serial cyclic buffer. 

Parameter | Description
--- | --- 
*gpio*| 0-31
*buf_Size| >=0
returns| Returns two-elements list. The first element is the number of bytes copied if OK, otherwise PI_BAD_USER_GPIO or PI_NOT_SERIAL_GPIO. The second element is the binary string of bytes returned for each character depend upon the number of data bits data_bits specified in the bb_serial_read_open command. 

For data_bits 1-8 there will be one byte per character.
For data_bits 9-16 there will be two bytes per character.
For data_bits 17-32 there will be four bytes per character.

### bb_serial_read_close *pi gpio*
  This function closes a GPIO for bit bang reading of serial data.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31, previously opened with *`bb_serial_read_open`*.
returns| Returns zero if OK, otherwise PI_BAD_USER_GPIO, or PI_NOT_SERIAL_GPIO.

### bb_serial_invert     *pi gpio invert*
  This function inverts serial logic for big bang serial reads. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*gpio*| 0-31, previously opened with *`bb_serial_read_open`*.
*invert*| 0-normal, 1-invert
returns| Returns 0 if OK, otherwise PI_NOT_SERIAL_GPIO or PI_BAD_SER_INVERT.

# I2C
### i2c_open             *pi i2c_bus i2c_addr i2c_flags*
  This returns a handle for the device at address i2c_addr on bus i2c_bus.
  
Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*i2c_bus*| >=0
*i2c_addr*| 0 - 0x7F, I2C device address
*i2c_flags*| 0 
returns| Returns a handle (>=0) if OK, otherwise PI_BAD_I2C_BUS, PI_BAD_I2C_ADDR, PI_BAD_FLAGS, PI_NO_HANDLE, or PI_I2C_OPEN_FAILED.

No flags are currently defined. This parameter should be set to zero. Physically buses 0 and 1 are available on the Pi.

### i2c_close            *pi handle*
  This closes the I2C device associated with the handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
returns| Returns zero if OK, otherwise PI_BAD_HANDLE.

### i2c_write_quick      *pi handle bit*
   This sends a single bit (in the Rd/Wr bit) to the device associated with handle. This proc is useful
   to check if I2C non-volatile memory is busy or done with previously issued write command. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*bit*| 0-1, value to write.
returns| Returns zero if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_WRITE_FAILED.

### i2c_write_byte       *pi handle bVal*
  This sends a single byte to the device associated with handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
bVal| 0-0xFF, the value to write.
returns| Returns zero if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_WRITE_FAILED. 

### i2c_read_byte        *pi handle*
  This reads a single byte from the device associated with handle 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
returns| Returns the byte read (>=0) if OK, otherwise PI_BAD_HANDLE, or PI_I2C_READ_FAILED. 

### i2c_write_byte_data  *pi handle i2c_reg bVal*
 This writes a single byte to the specified register of the device associated with handle. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*i2c_reg*| 0 - 0xFF.
*bVal*| 0-0xFF, the value to write.
returns| Returns zero if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_WRITE_FAILED. 

### i2c_write_word_data  *pi handle i2c_reg wVal*
  This writes a single 16 bit word to the specified register of the device associated with handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*i2c_reg*| 0 - 0xFF.
*wVal*| 0-0xFFFF, the value to write.
returns| Returns zero if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_WRITE_FAILED. 

### i2c_read_byte_data   *pi handle i2c_reg*
  This reads a single byte from the specified register of the device associated with handle.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*i2c_reg*| 0 - 0xFF.
returns| Returns the byte read (>=0) if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_READ_FAILED.  

### i2c_read_word_data   *pi handle i2c_reg*
  This reads a single 16 bit word from the specified register of the device associated with handle.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*i2c_reg*| 0 - 0xFF.
returns| Returns the word read (>=0) if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_READ_FAILED.  

### i2c_process_call     *pi handle i2c_reg wVal*
  This writes 16 bits of data to the specified register of the device associated with handle and and reads 16 bits of data in return. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*i2c_reg*| 0 - 0xFF.
*wVal*| 0-0xFFFF, the value to write.
returns| Returns the word read (>=0) if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_READ_FAILED. 

### i2c_read_device      *pi handle count*
  This reads count bytes from the raw device.  

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*count*| >0, the number of bytes to read.
returns| Returns two-elements list. The first element is count (>0) if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_READ_FAILED. 
The second element is binary string of bytes returned for each character.

### i2c_write_device     *pi handle txBuf count*
  This writes count bytes from buf to the raw device.

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*txBuf*| binary data to write.
*count*| >0, the number of bytes to read.
returns| Returns 0 if OK, otherwise PI_BAD_HANDLE, PI_BAD_PARAM, or PI_I2C_WRITE_FAILED.

### i2c_zip              *pi handle txBuf txCount RxCount*
   This proc executes a sequence of I2C operations. The operations to be performed are specified by the contents of txBuf which        contains the concatenated command codes and associated data. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*handle*| >=0, as returned by a call to *`i2c_open`*.
*txBuf*| binary data to write.
*txCount*| >0, the number of bytes to write.
*rxCount*| >0, the number of bytes to read.
returns| Returns two-elemnts list. The first element is status code and if >= 0 operation was OK (the number of bytes read), otherwise PI_BAD_HANDLE, PI_BAD_POINTER, PI_BAD_I2C_CMD, PI_BAD_I2C_RLEN. PI_BAD_I2C_WLEN, or PI_BAD_I2C_SEG. The second element contains binary data read from the i2c device. 

The following command codes are supported: 

Name|	Cmd & Data	|Meaning
--|---|---
End|	0	|No more commands
Escape|	1|	Next P is two bytes
On	|2	|Switch combined flag on
Off|	3	|Switch combined flag off
Address|	4 P|	Set I2C address to P
Flags	|5 lsb msb|	Set I2C flags to lsb + (msb << 8)
Read	|6 P	|Read P bytes of data
Write	|7 P| ...	Write P bytes of data


The address, read, and write commands take a parameter P. Normally P is one byte (0-255). If the command is preceded by the Escape command then P is two bytes (0-65535, least significant byte first). The address defaults to that associated with the handle. The flags default to 0. The address and flags maintain their previous value until updated. The returned I2C data is stored in consecutive locations of outBuf. 

Example

```C
Set address 0x53, write 0x32, read 6 bytes
Set address 0x1E, write 0x03, read 6 bytes
Set address 0x68, write 0x1B, read 8 bytes
End

0x04 0x53   0x07 0x01 0x32   0x06 0x06
0x04 0x1E   0x07 0x01 0x03   0x06 0x06
0x04 0x68   0x07 0x01 0x1B   0x06 0x08
0x00
```

# BIT-BANG I2C
### bb_i2c_open          *pi SDA SCL baud*
   This function selects a pair of GPIO for bit banging I2C at a specified baud rate. Bit banging I2C allows for certain operations which are not possible with the standard I2C driver. 

- baud rates as low as 50
- repeated starts
- clock stretching
- I2C on any pair of spare GPIO

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*SDA*| SDA gpio pin 0-31
*SCL*| SCL gpio pin 0-31
*baud*| 50-500000
returns| Returns zero if OK, otherwise PI_BAD_USER_GPIO, PI_BAD_I2C_BAUD, or PI_GPIO_IN_USE.

*`NOTE:
The GPIO used for SDA and SCL must have pull-ups to 3V3 connected. As a guide the hardware pull-ups on pins 3 and 5 are 1k8 in value.`*

### bb_i2c_close         *pi SDA*
  This function stops bit banging I2C on a pair of GPIO previously opened with *`bb_i2c_open`*. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| Returns zero if OK, otherwise PI_BAD_USER_GPIO, or PI_NOT_I2C_GPIO.


### bb_i2c_zip           *pi SDA txBuf txCount rxCount*
  This function executes a sequence of bit banged I2C operations. The operations to be performed are specified by the contents of inBuf which contains the concatenated command codes and associated data. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
*SDA*| 0-31 (as used in a prior call to bb_i2c_open)
*txBuf*| binary data to write
*txCount*| bytes to write
*rxCount*| bytes to read
returns| Returns >= 0 if OK (the number of bytes read), otherwise PI_BAD_USER_GPIO, PI_NOT_I2C_GPIO, PI_BAD_POINTER, PI_BAD_I2C_CMD, PI_BAD_I2C_RLEN, PI_BAD_I2C_WLEN, PI_I2C_READ_FAILED, or PI_I2C_WRITE_FAILED. 

The following command codes are supported: 

Name|	Cmd & Data	|Meaning
---|---|---
End	|0	|No more commands
Escape	|1|	Next P is two bytes
Start	|2	|Start condition
Stop	|3	|Stop condition
Address	|4 |P	Set I2C address to P
Flags	|5 |lsb msb	Set I2C flags to lsb + (msb << 8)
Read	|6 | P	Read P bytes of data
Write	|7 | P ...	Write P bytes of data


The address, read, and write commands take a parameter P. Normally P is one byte (0-255). If the command is preceded by the Escape command then P is two bytes (0-65535, least significant byte first). 

The address and flags default to 0. The address and flags maintain their previous value until updated. No flags are currently defined. 
The returned I2C data is stored in consecutive locations of outBuf. 

Example
```
Set address 0x53
start, write 0x32, (re)start, read 6 bytes, stop
Set address 0x1E
start, write 0x03, (re)start, read 6 bytes, stop
Set address 0x68
start, write 0x1B, (re)start, read 8 bytes, stop
End

0x04 0x53
0x02 0x07 0x01 0x32   0x02 0x06 0x06 0x03

0x04 0x1E
0x02 0x07 0x01 0x03   0x02 0x06 0x06 0x03

0x04 0x68
0x02 0x07 0x01 0x1B   0x02 0x06 0x08 0x03

0x00

# BIT-BANG SPI
### bb_spi_open          *pi CS MISO MOSI SCLK baud spi_flags*
   This function selects a pair of GPIO for bit banging I2C at a specified baud rate. Bit banging I2C allows for certain operations which are not possible with the standard I2C driver. 

- baud rates as low as 50
- repeated starts
- clock stretching
- I2C on any pair of spare GPIO

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
### bb_spi_close         *pi CS*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
### bb_spi_xfer          *pi CS txBufrxBuf count*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None

# SPI
### spi_open             *pi spi_channel baud spi_flags*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
### spi_close            *pi handle*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
### spi_xfer             *pi handle txBuf rxBuf count*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None

# GPIO CALLBACK
### gpioCallback         *pi pio edge proc  userdata*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
### gpioCallbackDelete   *callback_id*
  ###### Terminates the connection to a pigpio daemon and releases resources used by the library. 

Parameter | Description
--- | --- 
*pi*| Handle returned by *`pigpio_start`*
returns| None
 
# EXAMPLES
All examples can be simply tested yourself on a breadboard with 
corresponding chips or you can buy cheap MDI2C dev board.

+ (tmp100-test.tcl)  TI TMP100  thermometer test 
+ (i2c-test.tcl)     Microchip 24AA512 NV memory test
+ (24aa515-test)     Microchip 24AA515 NV memory test
+ (rtc-test)         PCF8583 RTC + RAM + COUNTER test
+ (pcf8574-test.tcl) PCF8574 IO expander test
+ (pcf8591-test.tcl) PCF8591 DAC/ADC test
+ (spi-test)         Microchip   25AA640 NV memory test
+ (gpio-cb-test.tcl) GPIO Callbacks test
+ (gpio-test.tcl)    GPIO simple inout test
