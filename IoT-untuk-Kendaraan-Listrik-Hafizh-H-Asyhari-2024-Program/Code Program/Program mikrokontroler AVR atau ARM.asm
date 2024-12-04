; Program Assembly AVR - Baca sensor arus dan tegangan (Analog)
; dan kirimkan data melalui komunikasi serial (USART)

.include "m32def.inc"   ; Menggunakan mikrocontroller AVR ATmega32

.org 0x00
rjmp RESET

RESET:
    ldi r16, 0x00      ; Reset register
    out DDRB, r16      ; Set PORTB sebagai input
    out DDRA, 0xFF     ; Set PORTA sebagai output (untuk sensor)

    ; Mengatur USART
    ldi r16, 0x0C
    out UBRRH, r16      ; Set baud rate 9600
    ldi r16, 0x83
    out UCSRB, r16      ; Enable receiver and transmitter
    ldi r16, 0x67
    out UCSRC, r16      ; Asynchronous mode, 8-bit data, 1 stop bit

main_loop:
    ; Baca sensor arus dan tegangan
    in r16, PINA        ; Baca input analog
    out PORTB, r16      ; Kirimkan nilai ke PORTB (misalnya untuk LED atau indikator)

    ; Kirimkan data via USART (misalnya data sensor)
    ldi r18, 'A'        ; Kirimkan karakter 'A'
    out UDR, r18        ; Kirimkan data ke serial
    ; Proses lainnya

    rjmp main_loop      ; Ulangi

