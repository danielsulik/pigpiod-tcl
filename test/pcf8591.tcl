#
# NXP PCF8591  driver
#
package require pigpiod_tcl 1.0

set PCF8591debug 0
proc PCF8591DebugEnable { } {
    set ::PCF8591debug 1
}

proc PCF8591DebugDisable { } {
    set ::PCF8591debug 0
}

array set PCF8591Ctrl {}

proc PCF8591WriteCTRLReg { pi ChipAddr Data } {
    global PCF8591Ctrl
    
    set  ::PCF8591Ctrl([expr $ChipAddr]) $Data
    set  i2c  [i2c_open         $pi 1 $ChipAddr 0]
    set  rc   [i2c_write_device $pi $i2c [binary format c $Data] 1]
    set  rc   [i2c_close        $pi $i2c]
}

proc PCF8591WriteDACReg { pi ChipAddr Data } {
    global ::PCF8591Ctrl
    set  bData [binary format c $Data]
    set  bCtrl [binary format c $::PCF8591Ctrl([expr $ChipAddr])]
    set  i2c   [i2c_open         $pi 1 $ChipAddr 0]
    set  rc    [i2c_write_device $pi $i2c $bCtrl$bData 2]
    set  rc    [i2c_close        $pi $i2c]
}

proc PCF8591ReadADCCurrent { pi ChipAddr Count } {
    set  i2c    [i2c_open        $pi 1 $ChipAddr 0]
    set  RDData [i2c_read_device $pi $i2c $Count ]
    if { $::PCF8591debug } {
        puts RDBytes=[lindex $RDData 0]
    }
    set  rc     [i2c_close $pi $i2c]
    return      [lindex $RDData 1]
}

