#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "------------------------------"
puts "      GPIO callback test"
puts "------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

source ./tmp100.tcl

set ::done 0
set mon 0
proc gpioCB { gpio level tick } { 
    puts "ISR: GPIO:$gpio changed to $level at T:$tick"
}

proc finish { gpio level tick } { 
    global mon
    puts "ISR: GPIO:$gpio changed to $level at T:$tick"
    puts "Finsih requested"
    set ::mon 1
}

proc Monitor {pi} {
    global mon
    if { $mon } { 
        set ::done 1 
    } else {
        puts "Temperature: [TMP100ReadTemp $pi 0x4E] deg.C"
        after 10 Monitor $pi
    }
}

set_mode          $pi 4 $::PI_INPUT
set_pull_up_down  $pi 4 $::PI_PUD_UP
set_mode          $pi 17 $::PI_INPUT
set_pull_up_down  $pi 17 $::PI_PUD_UP
set_mode          $pi 18 $::PI_INPUT
set_pull_up_down  $pi 18 $::PI_PUD_UP
set_mode          $pi 27 $::PI_INPUT
set_pull_up_down  $pi 27 $::PI_PUD_UP
set_mode          $pi 22 $::PI_INPUT
set_pull_up_down  $pi 22 $::PI_PUD_UP
set_mode          $pi 23 $::PI_INPUT
set_pull_up_down  $pi 23 $::PI_PUD_UP
set_mode          $pi 24 $::PI_INPUT
set_pull_up_down  $pi 24 $::PI_PUD_UP

set_mode          $pi 24 $::PI_INPUT
set_pull_up_down  $pi 24 $::PI_PUD_UP

#Set callback proc for change on pin 4
set g4cbh  [gpioCallback $pi  4 $::FALLING_EDGE gpioCB 0]
set g17cbh [gpioCallback $pi 17 $::FALLING_EDGE gpioCB 0]
set g18cbh [gpioCallback $pi 18 $::FALLING_EDGE gpioCB 0]
set g27cbh [gpioCallback $pi 27 $::FALLING_EDGE gpioCB 0]
set g22cbh [gpioCallback $pi 22 $::FALLING_EDGE gpioCB 0]
set g23cbh [gpioCallback $pi 23 $::FALLING_EDGE gpioCB 0]

set g24cbh [gpioCallback $pi 24 $::FALLING_EDGE finish 0]

#monitor finish request
Monitor $pi
vwait ::done

#Delete callbacks
gpioCallbackDelete $g4cbh
gpioCallbackDelete $g17cbh
gpioCallbackDelete $g18cbh
gpioCallbackDelete $g27cbh
gpioCallbackDelete $g22cbh
gpioCallbackDelete $g23cbh
gpioCallbackDelete $g24cbh

pigpio_stop $pi
