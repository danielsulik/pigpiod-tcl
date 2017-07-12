#
# Microchip 24AA512 driver
#
package require pigpiod_tcl 1.0

set M24AA512_PAGE_SIZE       128
set M24AA512_WRITE_TIMEOUT     5; #max write time in ms
set M24AA512_MEMORY_SIZE   65536

set M24AA512debug 0
proc M24AA512DebugEnable { } {
    set ::M24AA512debug 1
}

proc M24AA512DebugDisable { } {
    set ::M24AA512debug 0
}

proc M24AA512MemSize {} { return $::M24AA512_MEMORY_SIZE }

proc M24AA512Write { pi ChipAddr Address Data } {
    set Len   [string length $Data]
    set Idx   0
    set  i2c  [i2c_open $pi 1 $ChipAddr 0]
    if { $i2c < 0 } {
        puts "ERROR:[lindex [info level 0] 0 ]:[pigpio_error $rc]"
        return -1
    }
    
    set Ret 0
    while { $Len } {
        set ADDR [format %04X $Address]

        if { $Len > $::M24AA512_PAGE_SIZE } {
            set Chunk $::M24AA512_PAGE_SIZE
        } else {
            set Chunk $Len
        }
        set Rem [expr $Address % $::M24AA512_PAGE_SIZE]
        if { $Rem != 0 } {
            set n [expr $::M24AA512_PAGE_SIZE - $Rem]
            if { $Chunk > $n } {
                set Chunk $n
            }
        }
        
        #puts A=$ADDR,C=$Chunk
        set Buf [string range $Data $Idx [expr $Idx + $Chunk]]
        #DumpBinData 0 [binary format H* $ADDR]$Buf
        set rc  [i2c_write_device  $pi $i2c [binary format H* $ADDR]$Buf [expr 2 + $Chunk]]
        if { $rc < 0 } {
            puts "ERROR:[lindex [info level 0] 0 ]:[pigpio_error $rc]"
            set Ret -1
            break
        }

        #wait until write done
        set tmo 0
        while { [i2c_write_quick $pi $i2c 0] != 0 } {
            if { $tmo > $::M24AA512_WRITE_TIMEOUT } {
                puts "ERROR:[lindex [info level 0] 0 ]:timout"
                set Ret -1
                break;
            }
            after 1
            incr  tmo
        }
        
        if { $Ret < 0 } {
            break
        }
        set Address [expr $Address + $Chunk]
        set Idx     [expr $Idx     + $Chunk]
        set Len     [expr $Len     - $Chunk]
    }
    if { [i2c_close $pi $i2c] < 0 } {
        return -1
    }
    return $Ret
}

proc M24AA512Read { pi ChipAddr Address Count } {
    set ADDR [format %04X $Address]
    set  i2c    [i2c_open          $pi 1 $ChipAddr 0]
    if { $i2c < 0 } {
        puts "ERROR:[lindex [info level 0] 0 ]:[pigpio_error $rc]"
        return -1
    }
    set  rc     [i2c_write_device  $pi $i2c [binary format H* $ADDR] 2]
    if { $rc < 0 } {
        puts "ERROR:[lindex [info level 0] 0 ]:[pigpio_error $rc]"
        return -1
    }
    set  RDData [i2c_read_device   $pi $i2c $Count ]
    set  rc [i2c_close $pi $i2c]
    if { $rc < 0 } {
        puts "ERROR:[lindex [info level 0] 0 ]:[pigpio_error $rc]"
        return -1
    }
    return [lindex $RDData 1]
}