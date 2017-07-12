#
# Microchip 24AA512 driver
#
package require pigpiod_tcl 1.0

set CMD_WRSR  01
set CMD_WRITE 02
set CMD_READ  03
set CMD_WRDI  04
set CMD_RDSR  05FF
set CMD_WREN  06

set M25AA640_SPI_RATE  2500000
set M25AA640_PAGE_SIZE      32
set M25AA640_WRITE_TIMEOUT   6; #max write time in ms
set M25AA640_MEMORY_SIZE  8192


set M25AA640debug 0
proc M25AA640DebugEnable {} {
    set ::M25AA640debug 1
}

proc M25AA640DebugDisable {} {
    set ::M25AA640debug 0
}

proc M25AA640MemSize { } { return $::M25AA640_MEMORY_SIZE }

proc M25AA640StatusRead { pi ChipAddr } {
    set spi     [spi_open  $pi $ChipAddr $::M25AA640_SPI_RATE 0]
    if {$spi < 0} {
        return -1;
    }
    set Res     [spi_xfer  $pi $spi [binary format H* $::CMD_RDSR] 2]
    if { [spi_close $pi $spi] < 0 } {
        return -1;
    }
    binary scan [string range [lindex $Res 1] 1 1] H* R
    if { $::M25AA640debug } {
        puts   "M25AA640-SR:0x$R"
    }
    return 0x$R
}

proc M25AA640StatusWrite { pi ChipAddr Value } {
    set V     [format %02X $Value]
    set spi   [spi_open  $pi $ChipAddr $::M25AA640_SPI_RATE 0]
    if {$spi < 0} {
        return -1;
    }
    set Res   [spi_xfer  $pi $spi [binary format H* $::CMD_WRSR$V] 2 ]
    if { [spi_close $pi $spi] < 0 } {
        return -1;
    }
    return [lindex $Res 0]
}

proc M25AA640Write { pi ChipAddr Address Data } {
    
    set Len   [string length $Data]
    set Idx   0
    set spi   [spi_open $pi $ChipAddr $::M25AA640_SPI_RATE 0]
    set Ret 0
    
    while { $Len } {
        set ADDR  [format %04X $Address]
        set rc    [spi_xfer $pi $spi [binary format H* $::CMD_WREN ] 1]
        
        if { $Len > $::M25AA640_PAGE_SIZE } {
            set Chunk $::M25AA640_PAGE_SIZE
        } else {
            set Chunk $Len
        }
        set Rem [expr $Address % $::M25AA640_PAGE_SIZE]
        if { $Rem != 0 } {
            set n [expr $::M25AA640_PAGE_SIZE - $Rem]
            if { $Chunk > $n } {
                set Chunk $n
            }
        }
        
        #puts A=$ADDR,C=$Chunk
        set Buf [string range $Data $Idx [expr $Idx + $Chunk]]
        set rc  [spi_xfer $pi $spi [binary format H* $::CMD_WRITE$ADDR]$Buf [expr 3 + $Chunk]]
        if { $rc < 0 } {
            puts "ERROR:[lindex [info level 0] 0 ]:[pigpio_error $rc]"
            set Ret -1
            break
        }

        #wait until write done
        set tmo 0
        while {[M25AA640StatusRead $pi $ChipAddr] & 0x01 } {
            if { $tmo > $::M25AA640_WRITE_TIMEOUT } {
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
    if { [spi_close $pi $spi] < 0 } {
        return -1;
    }
    return $Ret
}

proc M25AA640Read { pi ChipAddr Address Count } {
    set ADDR  [format %04x $Address]
    set dummy ""
    for { set i 0 } { $i < $Count} { incr i } {
        append dummy FF
    }
    set spi     [spi_open  $pi $ChipAddr $::M25AA640_SPI_RATE 0]
    set RDData  [spi_xfer  $pi $spi [binary format H* $::CMD_READ$ADDR$dummy] [expr 3 + $Count] ]
    set rc      [spi_close $pi $spi]
    return [string range [lindex $RDData 1] 3 [string length [lindex $RDData 1]]]
}
