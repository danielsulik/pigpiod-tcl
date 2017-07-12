# ST LSM303C accelerator/magnetometer driver
package require pigpiod_tcl 1.0

set MagMdebug 0
proc MagMDebugEnable { } {
    set ::MagMdebug 1
}

set ::MAGM_CSM       4
set ::MAGM_CSA      17
set ::MagMChipAddr  0x1E
set ::MagMGainList  [list 1]
set ::MagMRangeList [list 16]

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
     return [expr $cnt * 0.00058]
}

proc MagMDebugDisable { } {
    set ::MagMdebug 0
}

proc MagMInit { pi } {
   gpio_write $pi  $::MAGM_CSM 1
   gpio_write $pi  $::MAGM_CSA 1
   set_mode   $pi  $::MAGM_CSM $::PI_OUTPUT
   set_mode   $pi  $::MAGM_CSA $::PI_OUTPUT
}

proc MagMDeInit { pi } {
   set_mode   $pi  $::MAGM_CSM $::PI_INPUT
   set_mode   $pi  $::MAGM_CSA $::PI_INPUT
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
    return [MagMRead $pi 0x0F 1]
}

proc MagMReadConfigReg1 { pi } {
    return [MagMRead $pi 0x20 1]
}

# te [7]   thermometer enable
# om [6:5] operation mode 00 low power 
#                        01 medium performnce 
#                        10 high performnce 
#                        11 ultra-high performnce 
# rate [4:2] rate (Hz) 000=0.625, 001=1.25, 010=2.5, 011=5
#                      100=10,    101=20,   110=40,  111=80
# bit    [1] = 0 
# bit  St[0] self test 
proc MagMWriteConfigReg1 { pi te om rate st } {
    set v  [expr (($te & 0x1) << 7) + (($om & 0x3) << 5) + (($rate & 0x7)<<2) + ($st & 0x1)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0x20 $d]
}

proc MagMReadConfigReg2 { pi } {
    return [MagMRead $pi 0x21 1]
}

# bit   [7]   = 0
# bit   [6:5]  full scale
#              xx not used
#              11 full scale
# bit   [4]   = 0
# bit   [3]   = Reboot 
# bit   [2]   = Soft reset 
# bit   [1:0] = 00
proc MagMWriteConfigReg2 { pi gain rb rst } {
    set v  [expr (($gain & 0x3) << 5) + (($rb & 1) << 3) + (($rst & 1) << 2)]
    set d  [binary format cu $v]
    return [MagMWrite $pi 0x21 $d]
}

proc MagMReadConfigReg3 { pi } {
    return [MagMRead $pi 0x22 1]
}

# bit [7] I2C disable
# bit [6] = 0
# bit [5] LP low power mode
# bit [4] = 0
# bit [3] = 0
# bit [2] = SPI select
# bit [1:0] = operation mode 00=continuous,01=Single conversion, 1X=power down
proc MagMWriteConfigReg3 { pi lp om } {
    set v [expr (($lp & 0x1) << 5) + (($om & 0x3) << 0)]
    set d [binary format cu $v]
    return [MagMWrite $pi 0x22 $d]
}

proc MagMReadConfigReg4 { pi } {
    return [MagMRead $pi 0x23 1]
}

# bit [7:4] =0000
# bit [3:2] = Operation mode z axis,00=low,01=medium, 10=high, 11=ultra performance
# bit [1]   = Big/little endian
# bit [0]   = 0
proc MagMWriteConfigReg4 { pi omz ble } {
    set v [expr (($omz & 0x3) << 2) + (($ble & 0x1) << 1)]
    set d [binary format cu $v]
    return [MagMWrite $pi 0x23 $d]
}

proc MagMReadConfigReg5 { pi } {
    return [MagMRead $pi 0x24 1]
}

# bit [7] = 0
# bit [6] = Block data update
# bit [5:0] =000000
proc MagMWriteConfigReg5 { pi bdu } {
    set v [expr (($bdu & 0x1) << 6)]
    set d [binary format cu $v]
    return [MagMWrite $pi 0x24 $d]
}

proc MagMConfigure { pi gain } {
    MagMWriteConfigReg1   $pi  1 3 4 0
    MagMWriteConfigReg2   $pi  3 0 0
    MagMWriteConfigReg3   $pi  0 0
    MagMWriteConfigReg4   $pi  0 0
    MagMWriteConfigReg5   $pi  0
}

proc MagMConfigurationRead { pi } {
    binary scan [MagMReadConfigReg1 $pi ] H* n
    puts "REG1:   0x$n"
    binary scan [MagMReadConfigReg2 $pi ] H* n
    puts "REG2:   0x$n"
    binary scan [MagMReadConfigReg3 $pi ] H* n
    puts "REG3:   0x$n"
    binary scan [MagMReadConfigReg4 $pi ] H* n
    puts "REG4:   0x$n"
    binary scan [MagMReadConfigReg5 $pi ] H* n
    puts "REG5:   0x$n"
}

proc MagMReadMagX { pi } {
    set X [MagMRead $pi 0x28 2]
    binary scan $X s n
    return $n
}

proc MagMReadMagY { pi } {
    set Y [MagMRead $pi 0x2A 2]
    binary scan $Y s n
    return $n
}

proc MagMReadMagZ { pi } {
    set Z [MagMRead $pi 0x2C 2]
    binary scan $Z s n
    return $n
}

proc MagMReadMagXYZ { pi } {
    set xyz [MagMRead $pi 0x28 6]
    binary scan $xyz sss x y z
    return [list $x $y $z]
}

proc MagMReadStatusReg { pi } {
    return [MagMRead $pi 0x27 1]
}

proc MagMReadTempReg { pi } {
    set temp [MagMRead $pi 0x2E 2]
    binary scan $temp s n
    return $n
}

proc MagMSelfTest { pi } {
    puts "Magnetic self-test"
    MagMWriteConfigReg1   $pi  0 0 4 1
    MagMWriteConfigReg2   $pi  3 0 0
    MagMWriteConfigReg3   $pi  0 0
    MagMWriteConfigReg4   $pi  0 0
    MagMWriteConfigReg5   $pi  0

    for { set i 0 } { $i < 3 } { incr i } {
        after 100
        set lxyz [ MagMReadMagXYZ $pi]
        set x    [lindex $lxyz 0]
        set y    [lindex $lxyz 1]
        set z    [lindex $lxyz 2]
        set x    [MagMCount2Gauss 1 $x]
        set y    [MagMCount2Gauss 1 $y]
        set z    [MagMCount2Gauss 1 $z]
        if { $i > 1 } {
            if { ($x > -1.0) || ($x < -3.0) || ($y > -1.0) || ($y < -3.0) || ($z > -0.1) || ($z < -1.0)} {
                puts "ERROR: sensor out of range!"
                puts "X: $x Gauss"
                puts "Y: $y Gauss"
                puts "Z: $z Gauss"
            }
        }
    }
    
     MagMConfigure $pi -
     after 100
}

proc MagMTempCalibration {} {
}
