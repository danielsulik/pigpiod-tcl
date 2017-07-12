#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "--------------------------------------------------------"
puts "                   GPIO notify test"
puts "  Uses GPIO 4 and 17 to capture H->L transition "
puts "  and calls corresponding callback proc."
puts "  Uses GPIO 24  to capture H->L transition and exits"
puts "  NOTE: This works on localhost only."
puts "--------------------------------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

#
# Init GPIO 4 and 24 as interrupt
# Enable pull-ups
#
set_mode          $pi  4 $::PI_INPUT
set_pull_up_down  $pi  4 $::PI_PUD_UP
set_mode          $pi 17 $::PI_INPUT
set_pull_up_down  $pi 17 $::PI_PUD_UP
set_mode          $pi 24 $::PI_INPUT
set_pull_up_down  $pi 24 $::PI_PUD_UP

set ::stop 0

#GPIO 4 callback
proc gpio4R {pi pin level tick} {
    puts "PIN change: pin:$pin l:$level t:$tick"
}

#GPIO 17 callback
proc gpio17F {pi pin level tick} {
    gpio4R $pi $pin $level $tick
}

#GPIO 24 callback
proc gpio24F {pi pin level tick} {
    puts "stop request: pin:$pin l:$level t:$tick"
    set ::done 1
}

#
#Init callback controller
#
set cbh [gpioCallbackInit $pi]

while {1} {
#Register gpio4R callback on GPIO 4
if { [gpioCallbackRegister $pi $cbh  4 0 gpio4R] < 0 } {
    return -1
}
#Register gpioX callback on GPIO 17
if { [gpioCallbackRegister $pi $cbh  17 0 gpio17F] < 0 } {
    return -1
}
#Register gpio24L callback (falling edge)
if { [gpioCallbackRegister $pi $cbh 24 0 gpio24F] < 0 } {
    return -1
}

vwait done
break
}

gpioCallbackRemove $pi $cbh  4
gpioCallbackRemove $pi $cbh 17
gpioCallbackRemove $pi $cbh 24
gpioCallbackStop   $pi $cbh
pigpio_stop $pi
