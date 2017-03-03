.equ TIMSK = $39
.equ TCCR0 = $33
.equ TCNT0 = $33
.equ PORTA = $1b ;вывод
.equ DDRA = $1a 
.equ PINB = $16 ;ввод
.equ PORTB = $18
.equ DDRB = $17
.equ SPH = $3e
.equ SPL = $3d
.equ ORC0 = $3C






.cseg
rjmp RESET
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
rjmp timer
main:
	clr r18
	
	ldi r19, $ff
	loop:
		inc r18
		clr r20
		loop2:
			inc r20
			cpse r20, r18
			rjmp loop2
		cpse r19, r18
		rjmp loop
	inc r17
	out PORTA, r17
	rjmp main
RESET:
	clr r16
	out DDRB, r16 ;зделали PORTB вводом
	ser r16
	out DDRA, r16 ;зделали PORTB выводом
	;out PORTB, r16 ;Включили автоподтягивание
	;ldi r16, $02
	;out TIMSK, r16
	;ldi r16, $04
	;out TCCR0, r16
	;ldi r16, $02
	;out ORC0, r16
	;sei
	clr r17
	rjmp main
timer:
	inc r17
	out PORTA, r17
	ldi r16, $02
	out ORC0, r16
	clr r16
	out TCNT0, r16
	rjmp main
