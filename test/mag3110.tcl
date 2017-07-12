# NXP MAX3110 magnetometer driver
package require pigpiod_tcl 1.0

set MagMdebug 0
proc MagMDebugEnable { } {
    set ::MagMdebug 1
}

set ::MAGM_DRDY     4
set ::MagMChipAddr  0x0E
set ::MagMGainList  [list 1]
set ::MagMRangeList [list 10]

proc MagMGainListGet { } {
     return $::MagMGainList
}

proc MagMGainIdx2Gain { gain  } {
     return [lindex $::MagMGainList $gain]
}

proc MagMGainValue2HwIdx { g } {
     return [lsearch $::MagMGainList $g ]
}

proc MagMGain2Range { g } {
     return  [lindex $::MagMRangeList $g] 
}

proc MagMCount2Gauss { gain cnt } {
     return [expr $cnt * 0.001]
}

proc MagMDebugDisable { } {
    set ::MagMdebug 0
}

proc MagMInit { pi } {
   set_mode  $pi  $::MAGM_DRDY $::PI_INPUT
}

proc MagMDeInit { pi } {
}

proc MagMWrite { pi Address Data } {
    set  ADDR  [format %02x $Address]
    set  i2c   [i2c_open         $pi 1 $::MagMChipAddr 0]
    set  rc    [i2c_write_device $pi $i2c [binary format H* $ADDR]$Data [expr 1 + [string length $Data]]]
    set  rc    [i2c_close        $pi $i2c]
}

proc MagMRead { pi Address Count } {
    MagMWrite $pi $Address ""
    set  i2c    [i2c_open        $pi 1 $::MagMChipAddr 0]
    set  RDData [i2c_read_device $pi $i2c $Count ]
    if { $::MagMdebug } {
        puts RDBytes=[lindex $RDData 0]
    }
    set  rc     [i2c_close $pi $i2c]
    return      [lindex $RDData 1]
}

proc MagMReadID { pi } {
    return [MagMRead $pi 0x07 1]
}

proc MagMReadSysMode { pi } {
    return [MagMRead $pi 0x08 1]
}

proc MagMReadConfigReg1 { pi } {
    return [MagMRead $pi 0x10 1]
}

# bit [7:5] rate
# bit [4:3] oversampling   XX low power 
#                          10 gives lowest noise
# bit [2] = FR full range  
# bit [1] = TM trigger
# bit [0] = AC perating mode active 
proc MagMWriteConfigReg1 { pi rate os fr tm ac } {
    set v  [expr (($rate & 0x7) << 5) + (($os & 0x3) << 3) + (($fr & 0x1) << 2) + (($tm & 0x1) << 1) + ($ac & 0x1)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0x10 $d]
}

proc MagMReadConfigReg2 { pi } {
    return [MagMRead $pi 0x11 1]
}

# bit   [7]  AutoRst
# bit   [6]  = 0
# bit   [5]  RAW
# bit   [4]  = 0
# bit   [3:0] = 0000
proc MagMWriteConfigReg2 { pi  arst raw magrst } {
    set v  [expr (($arst & 0x1) << 7) + (($raw & 1) << 5) + (($magrst & 1) << 4)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0x11 $d]
}

proc MagMConfigure { pi gain } {
    MagMWriteConfigReg2   $pi  1 1 1
    MagMWriteConfigReg1   $pi  0 0 0 1 0
    after 100
    MagMWriteConfigReg1   $pi  3 0 0 0 1
    after 100
    MagMWriteConfigReg2   $pi  1 1 0
}

proc MagMConfigurationRead { pi } {
    binary scan [MagMReadConfigReg1 $pi ] H* n
    puts "REG1:    0x$n"
    binary scan [MagMReadConfigReg2 $pi ] H* n
    puts "REG2:    0x$n"
    binary scan [MagMReadSysMode $pi ] H* n
    puts "SYSMODE: 0x$n"
}

proc MagMReadMagX { pi } {
    set X [MagMRead $pi 0x1 2]
    binary scan $X S n
    return $n
}

proc MagMReadMagY { pi } {
    set Y [MagMRead $pi 0x3 2]
    binary scan $Y S n
    return $n
}

proc MagMReadMagZ { pi } {
    set Z [MagMRead $pi 0x5 2]
    binary scan $Z S n
    return $n
}

proc MagMReadMagXYZ { pi } {
    set xyz [MagMRead $pi 0x1 6]
    binary scan $xyz SSS x y z
    return [list $x $y $z]
}

proc MagMWriteXOffsetReg { pi offset } {
    set d  [binary format cu $offset]
    return [MagMWrite $pi 0x9 $d]
}

proc MagMWriteYOffsetReg { pi offset } {
    set d  [binary format cu $offset]
    return [MagMWrite $pi 0xB $d]
}

proc MagMWriteZOffsetReg { pi offset } {
    set d  [binary format cu $offset]
    return [MagMWrite $pi 0xD $d]
}

proc MagMReadStatusReg { pi } {
    return [MagMRead $pi 0x0 1]
}

proc MagMReadTempReg { pi } {
    set temp [MagMRead $pi 0x0F 1]
    binary scan $temp c n
    return $n
}

proc MagMSelfTest { pi } {
    puts "No magnetic self-test"
}

proc MagMTempCalibration {} {
}
