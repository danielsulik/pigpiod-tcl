# Texas Instruments TMP100  driver
package require pigpiod_tcl 1.0

set TMP100_CFG_REG_ADDR   1
set TMP100_LOW_TEMP_ADDR  2
set TMP100_HIGH_TEMP_ADDR 3

proc TMP100WriteReg { pi ChipAddr Register Data } {
    set  Reg [format %02x $Register]
    set  Dt  [format %04x $Data]
    set  i2c [i2c_open         $pi 1 $ChipAddr 0]
    set  rc  [i2c_write_device $pi $i2c [binary format H* $Reg$Dt] 3]
    set  rc  [i2c_close        $pi $i2c]
}

proc TMP100ReadReg { pi ChipAddr Register } {
    set  Reg    [format %02x $Register]
    set  i2c    [i2c_open         $pi 1 $ChipAddr 0]
    set  rc     [i2c_write_device $pi $i2c [binary format H* $Reg] 1]
    set  RDData [i2c_read_device  $pi $i2c 2 ]
    set  rc     [i2c_close        $pi $i2c]
    binary scan [lindex $RDData 1] H* n
    return 0x$n
}

proc TMP100ReadTemp { pi ChipAddr } {
    set Temp [TMP100ReadReg $pi $ChipAddr 0]
    return   [expr $Temp / 256.0]
}
