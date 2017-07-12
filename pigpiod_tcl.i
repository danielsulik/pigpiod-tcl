%module pigpiod_tcl
%include "typemaps.i"

%typemap(in, numinputs=0) char *rxBuf {
    /* ignore rxBuf parameter */
}

%typemap(in, numinputs=0) void *rxBuf {
    /* ignore rxBuf parameter */
}

%typemap(argout) (char *rxBuf, unsigned count) {
    Tcl_Obj *o = Tcl_NewByteArrayObj ($1,$2);
    Tcl_ListObjAppendElement(interp,$result,o);
}

%apply unsigned char { uint8_t };
%apply unsigned int  { uint32_t };

extern int  pigpio_start      (char *addrStr, char *portStr);
extern void pigpio_stop       (int pi);

extern uint32_t get_current_tick      (int pi);
extern uint32_t get_hardware_revision (int pi);
extern uint32_t get_pigpio_version    (int pi);
extern unsigned pigpiod_if_version    (void);
extern char    *pigpio_error          (int errnum);

extern int  set_mode             (int pi, unsigned gpio, unsigned mode);
extern int  get_mode             (int pi, unsigned gpio);
extern int  set_pull_up_down     (int pi, unsigned gpio, unsigned pud);
extern int  gpio_read            (int pi, unsigned gpio);
extern int  gpio_write           (int pi, unsigned gpio, unsigned level);
extern int  get_pad_strength     (int pi, unsigned pad);
extern int  set_pad_strength     (int pi, unsigned pad, unsigned padStrength);

extern int set_PWM_dutycycle     (int pi, unsigned user_gpio, unsigned dutycycle);
extern int get_PWM_dutycycle     (int pi, unsigned user_gpio);
extern int set_PWM_range         (int pi, unsigned user_gpio, unsigned range);
extern int get_PWM_range         (int pi, unsigned user_gpio);
extern int get_PWM_real_range    (int pi, unsigned user_gpio);
extern int set_PWM_frequency     (int pi, unsigned user_gpio, unsigned frequency);
extern int get_PWM_frequency     (int pi, unsigned user_gpio);

extern int set_servo_pulsewidth  (int pi, unsigned user_gpio, unsigned pulsewidth);
extern int get_servo_pulsewidth  (int pi, unsigned user_gpio);

extern int notify_open           (int pi);
extern int notify_begin          (int pi, unsigned handle, uint32_t bits);
extern int notify_pause          (int pi, unsigned handle);
extern int notify_close          (int pi, unsigned handle);

extern int set_watchdog          (int pi, unsigned user_gpio, unsigned timeout);

extern int set_glitch_filter     (int pi, unsigned user_gpio, unsigned steady);
extern int set_noise_filter      (int pi, unsigned user_gpio, unsigned steady, unsigned active);

extern uint32_t read_bank_1      (int pi);
extern uint32_t read_bank_2      (int pi);
extern int      clear_bank_1     (int pi, uint32_t bits);
extern int      clear_bank_2     (int pi, uint32_t bits);
extern int      set_bank_1       (int pi, uint32_t bits);
extern int      set_bank_2       (int pi, uint32_t bits);

extern int hardware_clock        (int pi, unsigned gpio, unsigned clkfreq);
extern int hardware_PWM          (int pi, unsigned gpio, unsigned PWMfreq, uint32_t PWMduty);

int bb_serial_read_open          (int pi, unsigned user_gpio, unsigned baud, unsigned data_bits);
int bb_serial_read               (int pi, unsigned user_gpio, void *rxBuf, size_t bufSize);
int bb_serial_read_close         (int pi, unsigned user_gpio);
int bb_serial_invert             (int pi, unsigned user_gpio, unsigned invert);

int i2c_open                     (int pi, unsigned i2c_bus, unsigned i2c_addr, unsigned i2c_flags);
int i2c_close                    (int pi, unsigned handle);
int i2c_write_quick              (int pi, unsigned handle, unsigned bit);
int i2c_write_byte               (int pi, unsigned handle, unsigned bVal);
int i2c_read_byte                (int pi, unsigned handle);
int i2c_write_byte_data          (int pi, unsigned handle, unsigned i2c_reg, unsigned bVal);
int i2c_write_word_data          (int pi, unsigned handle, unsigned i2c_reg, unsigned wVal);
int i2c_read_byte_data           (int pi, unsigned handle, unsigned i2c_reg);
int i2c_read_word_data           (int pi, unsigned handle, unsigned i2c_reg);
int i2c_process_call             (int pi, unsigned handle, unsigned i2c_reg, unsigned wVal);
int i2c_read_device              (int pi, unsigned handle, char *rxBuf, unsigned count);
int i2c_write_device             (int pi, unsigned handle, char *txBuf, unsigned count);
int i2c_zip                      (int pi, unsigned handle, char *txBuf, unsigned inLen, char *rxBuf, unsigned count);

extern int bb_i2c_open           (int pi, unsigned SDA, unsigned SCL, unsigned baud);
extern int bb_i2c_close          (int pi, unsigned SDA);
extern int bb_i2c_zip            (int pi, unsigned SDA, char *txBuf, unsigned inLen, char *rxBuf, unsigned count);

extern int bb_spi_open           (int pi, unsigned CS, unsigned MISO, unsigned MOSI, unsigned SCLK, unsigned baud, unsigned spi_flags);
extern int bb_spi_close          (int pi, unsigned CS);
extern int bb_spi_xfer           (int pi, unsigned CS, char *txBuf,char *rxBuf, unsigned count);

extern int spi_open              (int pi, unsigned spi_channel, unsigned baud, unsigned spi_flags);
extern int spi_close             (int pi, unsigned handle);
extern int spi_xfer              (int pi, unsigned handle, char *txBuf, char *rxBuf, unsigned count);

/*
extern int serial_open           (int pi, char *ser_tty, unsigned baud, unsigned ser_flags);
extern int serial_close          (int pi, unsigned handle);
extern int serial_write_byte     (int pi, unsigned handle, unsigned bVal);
extern int serial_read_byte      (int pi, unsigned handle);
extern int serial_write          (int pi, unsigned handle, char *buf, unsigned count);
extern int serial_read           (int pi, unsigned handle, char *buf, unsigned count);
extern int serial_data_available (int pi, unsigned handle);
*/

/*
extern int gpioCallback          (int pi, unsigned user_gpio, unsigned edge, char *proc, void *userdata);
extern int gpioCallbackDelete    (unsigned callback_id);
*/

%init {
//    gpioCallbackInit ( );
}

%{
#include "pigpiod_if2.h"
#include <math.h>
%}

%inline %{
%}

/* GPIO function control */
#define PI_INPUT  0
#define PI_OUTPUT 1
#define PI_ALT0   4
#define PI_ALT1   5
#define PI_ALT2   6
#define PI_ALT3   7
#define PI_ALT4   3
#define PI_ALT5   2

/* GPIO pull-up/down resistors */
#define PI_PUD_OFF  0
#define PI_PUD_DOWN 1
#define PI_PUD_UP   2

/* GPIO level: 0-1 */
#define PI_OFF   0
#define PI_ON    1
#define PI_CLEAR 0
#define PI_SET   1
#define PI_LOW   0
#define PI_HIGH  1

/* Interrupts sensitivity */
#define RISING_EDGE  0
#define FALLING_EDGE 1
#define EITHER_EDGE  2
