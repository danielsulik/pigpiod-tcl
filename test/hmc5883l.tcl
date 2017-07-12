# Honeywell HCM5883L  driver
package require pigpiod_tcl 1.0

set MagMdebug 0
proc MagMDebugEnable { } {
    set ::MagMdebug 1
}

set ::MAGM_DRDY     4
set ::MagMChipAddr  0x1E
set ::MagMGainList  [list 1370 1090 820 660 440 390 330 230]
set ::MagMRangeList [list 0.88  1.3  1.9 2.5 4.0 4.7 5.6 8.1 ]

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

proc MagMGetLowLimit { gain } {
     set g [MagMGainIdx2Gain $gain]
     return [expr int(243.0 * $g/390.0)]
}

proc MagMGetHighLimit { gain } {
     set g [MagMGainIdx2Gain $gain]
     return [expr int(575.0 * $g/390.0)]
}

proc MagMCount2Gauss { gain cnt } {
     set g [MagMGainIdx2Gain $gain]
     return [expr $cnt * 1.0/$g]
}

proc MagMDebugDisable { } {
    set ::MagMdebug 0
}

proc MagMInit { pi } {
   set_mode   $pi  $::MAGM_DRDY $::PI_INPUT
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

proc MagMReadConfigRegA { pi } {
    return [MagMRead $pi 0 1]
}

# bit  [7] = 0
# avg  [6:5] Averaging 00 = sample, 01 = 2 samples, 10 = 4 sample, 11 = 8 samples 
# rate [4:2] rate      000 = 0.75Hz, 001 = 1.5Hz, 010=3Hz,   011=7.5Hz, 
#                      100 = 15Hz,   101 = 30Hz,  110 = 75Hz, 111 = Reserved 
# ms   [1:0] Measurement mode
#                      00 - normal operation
#                      01 - positive bias
#                      10 - negative bias
#                      11 - reserved
proc MagMWriteConfigRegA { pi avg rate ms } {
    set v  [expr (($avg & 0x3) << 5) + (($rate & 0x7)<<2) + ($ms & 0x3)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0 $d]
}

proc MagMReadConfigRegB { pi } {
    return [MagMRead $pi 1 1]
}

#
# set gain [7:5]
#
proc MagMWriteConfigRegB { pi gain } {
    set v  [expr ($gain & 0x7) << 5]
    set d  [binary format cu $v]
    return [MagMWrite $pi 1 $d]
}

proc MagMReadModeReg { pi } {
    return [MagMRead $pi 2 1]
}

# mode[1:0] 00 - continous measurement
#           01 - single measurement
#           10 - idle
#           11 - idle
# hs[7]     high speed I2C 400kHz 
proc MagMWriteModeReg { pi v } {
    set d [binary format cu [expr $v & 0x3]]
    return [MagMWrite $pi 2 $d]
}

#
#  avg  = 8 samples
#  rate = 15Hz
#  ms   = 0
#  gain = variable
#  mode = continous
proc MagMConfigure { pi gain } {
        MagMWriteConfigRegA   $pi  3 4 0
        MagMWriteConfigRegB   $pi  $gain
        MagMWriteModeReg      $pi  0
}

proc MagMConfigurationRead { pi } {
    binary scan [MagMReadConfigRegA $pi ] H* n
    puts "MagM CFGA:   0x$n"
    binary scan [MagMReadConfigRegB $pi ] H* n
    puts "MagM CFGB:   0x$n"
    binary scan [MagMReadModeReg $pi ] H* n
    puts "MagM Mode:   0x$n"
}

proc MagMReadMagX { pi } {
    set X [MagMRead $pi 3 2]
    binary scan $X S n
    return $n
}

proc MagMReadMagZ { pi } {
    set Z [MagMRead $pi 5 2]
    binary scan $Z S n
    return $n
}

proc MagMReadMagY { pi } {
    set Y [MagMRead $pi 7 2]
    binary scan $Y S n
    return $n
}

proc MagMReadMagXYZ { pi } {
    set xyz [MagMRead $pi 0x3 6]
    binary scan $xyz SSS x z y
    return [list $x $y $z]
}

proc MagMReadStatusReg { pi } {
    return [MagMRead $pi 9 1]
}

proc MagMReadID { pi } {
    return [MagMRead $pi 10 3]
}

proc MagMReadTempReg { pi } {
    return "N/A"
}

proc _MagMSelfTest { pi  gain } {
    puts "Magnetic self-test: Gain = $gain"
    MagMWriteConfigRegA   $pi  3 4 1; #self test, positive bias
    MagMWriteConfigRegB   $pi  $gain
    MagMWriteModeReg      $pi  0

    set rh [MagMGetHighLimit $gain];#puts $rh
    set rl [MagMGetLowLimit  $gain];#puts $rl
    
    for { set i 0 } { $i < 3 } { incr i } {
        after 100
        set lxyz [ MagMReadMagXYZ $pi]
        set x    [lindex $lxyz 0]
        set y    [lindex $lxyz 1]
        set z    [lindex $lxyz 2]
        if { $i > 1} {
            if { ($x > $rh) || ($x < $rl) || ($y > $rh) || ($y < $rl) || ($z > $rh) || ($z < $rl)} {
                puts "ERROR: sensor out of range"
                puts "X:      $x: [MagMCount2Gauss $gain $x] Gauss"
                puts "Y:      $y: [MagMCount2Gauss $gain $y] Gauss"
                puts "Z:      $z: [MagMCount2Gauss $gain $z] Gauss"
            }
        }
    }
    
    MagMWriteConfigRegA   $pi  3 4 0; #leave self test
    MagMWriteConfigRegB   $pi  0
    MagMWriteModeReg      $pi  0
    after 100
}

proc MagMSelfTest { pi } {
    _MagMSelfTest $pi  5
}

proc MagMTempCalibration {} {
}
