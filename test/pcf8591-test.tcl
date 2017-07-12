#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./pcf8591.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "------------------------------"
puts "       RTC PCF8591 Test"
puts " PCF8591 I2C address 0x48"
puts " Connect DAC output to AN0-3"
puts " Example generates saw signal."
puts "------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set ::ADC_VREF 2.5; #external reference set to 2.5V

proc Volt2Dec { Volt } {
    return [expr int(($Volt * 255) / $::ADC_VREF)]
}

proc ADCBin2Dec { bval } {
    binary scan $bval H2 n
    return [format "%.3f" [expr 0x$n / 255.0 * $::ADC_VREF]]
}

set Secs 60
set Volt 0.0
proc ReadADC { pi ChipAddr } {
    global done
    PCF8591WriteCTRLReg            $pi $ChipAddr 0x40
    set Ch0 [PCF8591ReadADCCurrent $pi $ChipAddr 2]
    PCF8591WriteCTRLReg            $pi $ChipAddr 0x41
    set Ch1 [PCF8591ReadADCCurrent $pi $ChipAddr 2]
    PCF8591WriteCTRLReg            $pi $ChipAddr 0x42
    set Ch2 [PCF8591ReadADCCurrent $pi $ChipAddr 2]
    PCF8591WriteCTRLReg            $pi $ChipAddr 0x43
    set Ch3 [PCF8591ReadADCCurrent $pi $ChipAddr 2]
    puts -nonewline "CH0: [ADCBin2Dec [string range $Ch0 1 1]]"
    puts -nonewline " CH1: [ADCBin2Dec [string range $Ch1 1 1]]"
    puts -nonewline " CH2: [ADCBin2Dec [string range $Ch2 1 1]]"
    puts -nonewline " CH3: [ADCBin2Dec [string range $Ch3 1 1]]\r"
    flush stdout

    #Write DAC with incremented value in 50mV steps    
    PCF8591WriteDACReg  $pi $ChipAddr [Volt2Dec $::Volt]
    set ::Volt [expr $::Volt + 0.05]
    if { $::Volt >= 2.5 } {
       set ::Volt 0.0
    }
    
    if { $::Secs } {
        set ::Secs [expr $::Secs - 1]
        after 100 ReadADC $pi $ChipAddr
    } else {
       set ::done 1
    }
}


set ChipAddr 0x48
PCF8591WriteCTRLReg $pi $ChipAddr 0x40
PCF8591WriteDACReg  $pi $ChipAddr [Volt2Dec 2.0]

ReadADC $pi $ChipAddr

vwait done
pigpio_stop $pi