\ UART and SPI test
\ Written by Rob Probin Jan 2023
\ Based on exampled from ZeptoForth
\ MIT License - see file LICENSE

\ some support words (from Tachyon)
: .HEX ( n cnt -- ) HEX  <# 0 DO # LOOP #> TYPE DECIMAL ;
: .B 0 2 .HEX ;
: .H 0 4 .HEX ;
: .L 0 8 .HEX ;
: >> rshift ;
: << lshift ;
: .BYTE [CHAR] $ EMIT .B ;


\ ========================================================================== 
\ similar to example at https://github.com/tabemann/zeptoforth/blob/master/test/rp2040/uart_echo.fs
\ Also see zeptoforth-0.54.0/docs/words/uart.html
\ 

uart import

\ Echo characters received by UART1 (GPIO pins 4, 5) at a given baud
: init-uart ( -- )
    1 8 uart-pin \ UART1 TX
    1 9 uart-pin \ UART1 RX
    38400 1 uart-baud!
;

\ RP2040 has 32 character FIFO for TX
: uart_tx ( addr u -- )
;

\ RP2040 has 32 character FIFO for RX
: uart_rx ( -- )
    begin 1 uart>? if 1 uart> dup emit 1 >uart then key? until
;


\ ========================================================================== 
\ 
\ Similar to example at https://github.com/tabemann/zeptoforth/blob/master/test/rp2040/spi_test_master.fs
\ Also see zeptoforth-0.54.0/docs/words/spi.html
\ 

spi import
pin import
task import


\ Initialize the test
: init-spi ( -- )
    0 16 spi-pin \ SPI1 RX
    \ 0 17 spi-pin \ SPI1 CSn  ... control this via GPIO
    17 OUTPUT-PIN
    0 18 spi-pin \ SPI1 SCK
    0 19 spi-pin \ SPI1 TX
    0 master-spi
    6500000 0 spi-baud! \ max baud rate without interbyte delays = 6.5MHz
    8 0 spi-data-size!
    0 ti-ss-spi
\    true false 0 motorola-spi
   0 enable-spi

;

: test_spi
    100 ms

    0 [: 355 256 do i 1 >spi 1 spi> . 1 ms loop ;] 256 128 512 spawn run
;

: read_version
   50 ms
   LOW 17 PIN!

   $31 128 + 0 >spi
   0 spi> .l
   0 0 >spi  \ filler byte
   0 spi> .l

   HIGH 17 PIN! 
;

: read_version2
   50 ms
   LOW 17 PIN!

   1 ms
   $31 128 + 0 >spi
   0 spi> hex . decimal
   0 0 >spi  \ filler byte
   0 spi> hex . decimal

   HIGH 17 PIN!
;


\ ========================================================================== 
\ 
\ Some led toggling to demo that feature

led import 
green toggle-led

: hi green toggle-led ;






