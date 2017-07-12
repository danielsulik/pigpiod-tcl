#
# NXP PCF8583  driver
#
package require pigpiod_tcl 1.0

set PCF8583_CTRL_ST_REG_ADDR       0
set PCF8583_TIME_100S_ADDR         1
set PCF8583_SEC_REG_ADDR           2
set PCF8583_MIN_REG_ADDR           3
set PCF8583_HOUR_REG_ADDR          4
set PCF8583_YEAR_DATE_REG_ADDR     5
set PCF8583_WEEKDAY_MONTH_REG_ADDR 6
set PCF8583_TIMER_REG_ADDR         7
set PCF8583_ALARM_CTRL_REG_ADDR    8
set PCF8583_ALARM_100S_ADDR        9
set PCF8583_ALARM_SECS_ADDR        10
set PCF8583_ALARM_MINS_ADDR        11
set PCF8583_ALARM_HOURS_ADDR       12
set PCF8583_ALARM_DATE_ADDR        13
set PCF8583_ALARM_MONTH_ADDR       14
set PCF8583_ALARM_TIMER_ADDR       15

set PCF8583_RAM_START_ADDR         0x10
set PCF8583_RAM_END_ADDR           0xFF

set PCF8583debug 0
proc PCF8583DebugEnable { } {
    set ::PCF8583debug 1
}

proc PCF8583DebugDisable { } {
    set ::PCF8583debug 0
}

proc PCF8583Write { pi ChipAddr Address Data } {
    set  ADDR  [format %02x $Address]
    set  i2c   [i2c_open         $pi 1 $ChipAddr 0]
    set  rc    [i2c_write_device $pi $i2c [binary format H* $ADDR]$Data [expr 1 + [string length $Data]]]
    set  rc    [i2c_close        $pi $i2c]
}

proc PCF8583Read { pi ChipAddr Address Count } {
    PCF8583Write $pi $ChipAddr $Address ""
    set  i2c    [i2c_open        $pi 1 $ChipAddr 0]
    set  RDData [i2c_read_device $pi $i2c $Count ]
    if { $::PCF8583debug } {
        puts RDBytes=[lindex $RDData 0]
    }
    set  rc     [i2c_close $pi $i2c]
    return      [lindex $RDData 1]
}

proc PCF8583RTCModeSet { pi ChipAddr } {
     PCF8583Write $pi $ChipAddr 0 [binary format H2 0]
}

proc PCF8583RTCTimeDateSet { pi ChipAddr T } {
     set T100  [format %02X 00]
     set Secs  [format %02X 0x[clock format $T -format %S]]
     set Mins  [format %02X 0x[clock format $T -format %M]]
     set Hours [format %02X 0x[clock format $T -format %H]]
     
     set Date  0x[clock format $T -format %d]
     set Month 0x[clock format $T -format %m]
     
     set Year  [expr [clock format $T -format %y] % 4]
     set Wday  [lsearch {Mon Tue Wed Thu Fri Sat Sun} [clock format $T -format %a]]
     
     set WdM   [format %02X [expr (($Wday << 5) + ($Month & 0x1F)) & 0xFF]]
     set YD    [format %02X [expr (($Year << 6) + ($Date  & 0x3F)) & 0xFF]]
    
     PCF8583Write $pi $ChipAddr 1 [binary format H* $T100$Secs$Mins$Hours$YD$WdM]
}

proc PCF8583RTCAlarmTimeSet { pi ChipAddr T Mode} {
     set T100  [format %02X 00]
     set Secs  [format %02X 0x[clock format $T -format %S]]
     set Mins  [format %02X 0x[clock format $T -format %M]]
     set Hours [format %02X 0x[clock format $T -format %H]]
     set Date  [format %02X 0x[clock format $T -format %d]]
     set Month [format %02X 0x[clock format $T -format %m]]
        
     PCF8583Write $pi $ChipAddr $PCF8583_ALARM_100S_ADDR [binary format H* $T100$Secs$Mins$Hours$Date$Month]
     PCF8583Write $pi $ChipAddr $::PCF8583_ALARM_CTRL_REG_ADDR [format %02X $Mode]
}

proc PCF8583SetCounterMode { pi ChipAddr } {
     PCF8583Write $pi $ChipAddr [binary format H2 20]
}
