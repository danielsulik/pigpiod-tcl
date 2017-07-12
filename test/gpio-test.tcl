#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "-----------------------------------------------"
puts "                  GPIO Test"
puts " Connect LEDs to the following GPIOs:"
puts "           4 17 18 27  22 23 24"
puts " To turn LED on drive high"
puts " The code stops after few seconds"
puts " NOTE: Make sure your pigpiod daemon is running"
puts "-----------------------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set LEDS { 4 17 18 27  22 23 24 }

proc LEDsInit { pi } {
    foreach led $::LEDS {
        set_mode   $pi  $led $::PI_OUTPUT
        gpio_write $pi $led 0
    }
}

proc LEDsDeInit { pi} {
    foreach led $::LEDS {
        gpio_write $pi $led 0
        set_mode   $pi $led $::PI_INPUT
    }
}

LEDsInit $pi

set Loop [expr 7 * 20]; #7 LEDS x 20 times
# Moving LEDs 1-by-1
set LedIdx 0
proc LEDsMove { pi } {
    global LedIdx done Loop
    
    #switch off previous LED
    gpio_write  $pi [lindex $::LEDS $LedIdx] 0
    set LedIdx [expr ($LedIdx + 1) % 7]
    #switch on next LED
    gpio_write  $pi [lindex $::LEDS $LedIdx] 1
    if { $Loop != 0 } {
        # start this proc after 100 ms again
        after 100  LEDsMove $pi
        set Loop [expr $Loop -1]
    } else {
        # stop and finish
        set done 1
    }
}

LEDsMove $pi
vwait done

LEDsDeInit $pi

pigpio_stop $pi
