#
# NXP PCF8574  driver
#
package require pigpiod_tcl 1.0

set PCF8574debug 0
proc PCF8574DebugEnable { } {
    set ::PCF8574debug 1
}

proc PCF8574DebugDisable { } {
    set ::PCF8574debug 0
}

proc PCF8574Write { pi ChipAddr Data } {
    set  i2c   [i2c_open          $pi 1 $ChipAddr 0]
    set  rc    [i2c_write_device $pi $i2c $Data [string length $Data]]
    set  rc    [i2c_close         $pi $i2c]
}

proc PCF8574Read { pi ChipAddr Count } {
    set  i2c    [i2c_open         $pi 1 $ChipAddr 0]
    set  RDData [i2c_read_device $pi $i2c $Count ]
    if { $::PCF8574debug } {
        puts RDBytes=[lindex $RDData 0]
    }
    set  rc     [i2c_close $pi $i2c]
    return      [lindex $RDData 1]
}
