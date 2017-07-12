# Invensense MPU9250 3-axis gyroscope, 3-axis accelerometer, 3-axis magnetometer driver
package require pigpiod_tcl 1.0

set MagMdebug 0
proc MagMDebugEnable { } {
    set ::MagMdebug 1
}

set ::MAGM_DRDY        4
set ::MagMChipAddr    0x0C
set ::MPU9250ChipAddr 0x69
set ::MagMGainList    [list 1]
set ::MagMRangeList   [list 48]
set ::MPU9250AdjX 128
set ::MPU9250AdjY 128
set ::MPU9250AdjZ 128


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
     return [expr $cnt * 0.006]
}

proc MagMDebugDisable { } {
    set ::MagMdebug 0
}

proc MagMInit { pi } {
   set_mode   $pi  $::MAGM_DRDY $::PI_INPUT
   #Bypass enable
   MPU9250Write      $pi 0x37 [binary format cu 2]
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

proc MPU9250Write { pi Address Data } {
    set  ADDR  [format %02x $Address]
    set  i2c   [i2c_open         $pi 1 $::MPU9250ChipAddr 0]
    set  rc    [i2c_write_device $pi $i2c [binary format H* $ADDR]$Data [expr 1 + [string length $Data]]]
    set  rc    [i2c_close        $pi $i2c]
}

proc MPU9250Read { pi Address Count } {
    MagMWrite $pi $Address ""
    set  i2c    [i2c_open        $pi 1 $::MPU9250ChipAddr 0]
    set  RDData [i2c_read_device $pi $i2c $Count ]
    if { $::MagMdebug } {
        puts RDBytes=[lindex $RDData 0]
    }
    set  rc     [i2c_close $pi $i2c]
    return      [lindex $RDData 1]
}

proc MagMReadID { pi } {
    return [MagMRead $pi 0x00 1]
}

proc MagMReadInfo { pi } {
    return [MagMRead $pi 0x01 1]
}

proc MagMReadStatusReg { pi } {
    return [MagMRead $pi 0x02 1]
}

proc MagMReadStatusReg2 { pi } {
    return [MagMRead $pi 0x09 1]
}

proc MagMReadControl1 { pi } {
    return [MagMRead $pi 0x0A 1]
}

#
# bit  [4]    1-16bit,0-14bit
# mode [3:0]  Mode 0000-power down,0001-single measurement mode,
#             0010-cont 1, 0110-cont3 mode, 0100-ext  trigger
#             1000-self test mode,1111-fuse access mode
proc MagMWriteControl1 { pi mode } {
    set v  [expr ($mode & 0xF)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0x0A $d]
}

proc MagMReadControl2 { pi } {
    return [MagMRead $pi 0x0B 1]
}

#
# SRST [0] 
proc MagMWriteControl2 { pi rst } {
    set v  [expr ($rst & 0x1)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0x0B $d]
}

proc MagMReadSelfTest { pi } {
    return [MagMRead $pi 0x0C 1]
}

#
# SELF TEST [6]
proc MagMWriteSelfTest { pi st } {
    set v  [ expr ($st & 0x1) << 6 ]
    set d  [ binary format cu $v ]
    return [ MagMWrite $pi 0x0C $d ]
}

proc MagMReadAdjX { pi } {
    return [MagMRead $pi 0x10 1]
}

proc MagMReadAdjY { pi } {
    return [MagMRead $pi 0x11 1]
}

proc MagMReadAdjZ { pi } {
    return [MagMRead $pi 0x12 1]
}

proc MagMConfigure { pi gain } {
    MagMWriteControl2 $pi  1
    after 100
    MagMWriteControl1 $pi  2
}

proc MagMConfigurationRead { pi } {
    binary scan [MagMReadID   $pi] H* n
    puts "ID:       0x$n"
    binary scan [MagMReadInfo $pi] H* n
    puts "INFO:     0x$n"
    binary scan [MagMReadStatusReg $pi] H* n
    puts "STAT1:    0x$n"
    binary scan [MagMReadStatusReg2 $pi] H* n
    puts "STAT2:    0x$n"
    binary scan [MagMReadControl1 $pi] H* n
    puts "CNTL1:    0x$n"
    binary scan [MagMReadControl2 $pi] H* n
    puts "CNTL2:    0x$n"
    binary scan [MagMReadSelfTest $pi] H* n
    puts "SELFTEST: 0x$n"
    binary scan [MagMReadAdjX $pi] cu n
    puts "ADJX:     $n"; set ::MPU9250AdjX $n
    binary scan [MagMReadAdjY $pi] cu n
    puts "ADJY:     $n"; set ::MPU9250AdjY $n
    binary scan [MagMReadAdjZ $pi] cu n
    puts "ADJZ:     $n"; set ::MPU9250AdjZ $n
}

proc MagMReadMagX { pi } {
    set X [MagMRead $pi 0x3 2]
    binary scan $X s n;
    set n [expr int ( (($::MPU9250AdjX - 128)/256.0 + 1.0) * $n)]
    return $n
}

proc MagMReadMagY { pi } {
    set Y [MagMRead $pi 0x5 2]
    binary scan $Y s n
    set n [expr int ( (($::MPU9250AdjY - 128)/256.0 + 1.0) * $n)]
    return $n
}

proc MagMReadMagZ { pi } {
    set Z [MagMRead $pi 0x7 2]
    binary scan $Z s n
    set n [expr int ( (($::MPU9250AdjZ - 128)/256.0 + 1.0) * $n)]
    MagMReadStatusReg2 $pi
    return $n
}

proc MagMReadMagXYZ { pi } {
    set xyz [MagMRead $pi 0x3 6]
    MagMReadStatusReg2 $pi
    binary scan $xyz sss x y z
    return [list $x $y $z]
}

proc MagMReadTempReg { pi } {
    set temp [MPU9250Read $pi 0x41 2]
    binary scan $temp S n
    return "N/A";#[expr ($n - 0)/1 + 21]
}

proc MagMSelfTest { pi } {
    puts "Magnetic self-test"
    MagMWriteControl1 $pi 8
    MagMWriteSelfTest $pi 1

    #TODO
    #This is not right
    for { set i 0 } { $i < 3 } { incr i } {
        after 100
        set x [MagMCount2Gauss 1 [ MagMReadMagX $pi ]]
        set y [MagMCount2Gauss 1 [ MagMReadMagY $pi ]]
        set z [MagMCount2Gauss 1 [ MagMReadMagZ $pi ]]
        after 100
        if { $i > 1 } {
            if { ($x > -1.0) || ($x < -3.0) || ($y > -1.0) || ($y < -3.0) || ($z > -0.1) || ($z < -1.0)} {
                puts "ERROR: sensor out of range!"
                puts "X: $x Gauss"
                puts "Y: $y Gauss"
                puts "Z: $z Gauss"
            }
        }
    }
    
    MagMWriteSelfTest $pi 0
    MagMConfigure $pi -
    after 100
}

proc MagMTempCalibration {} {
}
