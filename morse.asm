.equ TIMSK = $39
.equ TCCR0 = $33
.equ TCNT0 = $32
.equ DDRA = $1a 
.equ PORTA = $1b ;вывод
.equ DDRC = $14
.equ PORTC = $15
.equ PINB = $16 ;ввод
.equ DDRB = $17
.equ PORTB = $18
.equ PIND = $10
.equ DDRD = $11
.equ PORTD = $12
.equ SPH = $3e
.equ SPL = $3d
.def ZL= r30
.def ZH = r31
.set DOTT = $a0 ;время точек и тире в ~ милисекундах все что длиннее - тире  
.set PST = $3 ;время интервала между словами в четвертях олях секунды




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
rjmp TIMER0OVF
nop
nop
nop
nop
nop
nop
nop
nop
nop ;регистры r16 - для записи чисел в память, r19...21-аргументы функций
nop ;r2 - регистр режима работы, r3 - регистр состояний. r0, r1, r16 используются функциями на их усмотрение
nop ;r17 - регистр в котором хранится морзянка, r18 - символ в двоичном представлении
nop ;r22 - специальный регистр для таймера
main:
	rcall checkB 
	sbrs r4, 1
		rcall output_russian
	sbrs r4, 2
		rcall output_english
	sbrs r4, 0
		rcall B00 ;если низкий уровень на 0 входе порта B
	sbrc r4, 0
		rcall B01 ;если высокий уровень на 0 входе порта B
	mov r16, r3
	cpi r16, $04
	brge main
		mov r16, r3
		andi r16, $01 
		brne main ;если 0 или 2 уходим
			clr r16
			out TCNT0, r16
	rjmp main 
B00:
	mov r16, r2
	cpi r16, $02 
	brge b00end;если мы не считываем код морзянки то выходим из функции
	mov r16, r3
	cpi r16, $01
	breq b00end;если мы уже ждем . то все ок
	mov r16, r3
	cpi r16, $02
	breq b00end;если мы уже ждем - то все ок
		clr r3
		inc r3; в противном случае говорим что ждем точку
		clr r20
		ldi r19, DOTT
		rcall setT0; и ставим таймер
	b00end:
	ret
B01:
	mov r16, r2
	cpi r16, $02 
	brge b01end ;если мы не считываем код морзянки то выходим из функции
	mov r16, r3
	cpi r16, $03 
	brge b01end
	mov r16, r3
	cpi r16, $00
	breq b01end ;если состояние r3 не 1 или 2 (т.е если мы не ждем . или -) уходим
	lsl r17 ;переходим к следующему символу
	mov r16, r3
	cpi r16, $02
	brne b01next
	inc r17
	b01next:
	ldi r16, $03
	mov r3, r16
	ldi r20, PST
	ldi r19, $00
	rcall setT0
	b01end:
	ret
checkB:;проверка регистра B
	in r7, PINB; r7 - текущее состояние порта b, r6, r5 - два предыдущих r4 - подтвержденное состояние порта B
	mov r0, r7
	and r0, r6
	and r0, r5; r0 - маска единиц
	mov r1, r7
	or r1, r6
	or r1, r5; r1 - маска нулей
	and r4, r1
	or r4, r0; теперь в r4 - подтвержденное 3 циклами состояние порта B 
	mov r5, r6
	mov r6, r7  
	ret
RESET:
	clr r16
	out DDRB, r16 ;зделали PORTB вводом
	ser r16
	out DDRA, r16 ;зделали PORTB выводом
	out DDRC, r16 ;и PORTC тоже
	out PORTB, r16 ;Включили автоподтягивание
	ldi r16, $01
	out TIMSK, r16; препрывания по переполнению T0
	ldi r16, $05
	out TCCR0, r16
	ldi r16, $02;4 строчки - установка указателя стека
	out SPH, r16
	ldi r16, $5f
	out SPL, r16
	ldi r17, $01; базовое
	ser r16
	mov r4, r16
	mov r5, r16
	clr r18
	clr r22
	clr r2
	clr r3
	sei
	rjmp main
TIMER0OVF:
	push r16
	mov r16, r22
	tst r16
	brne next_step
	mov r16, r2
	cpi r16, $02 
	brge T0Oend ;если мы не считываем код морзянки то выходим из функции
	mov r16, r3
	cpi r16, $01
	brne T0Onext
		inc r3 ;теперь тире
		rjmp T0Oend
	T0Onext:
		mov r16, r3
		cpi r16, $03
		brne T0Oend
			mov r18, r17
			ldi r17, $01 ;
			clr r3
	rjmp T0Oend
	next_step:
		dec r22
		clr r16
		out TCNT0, r16
	T0Oend:
	pop r16
	reti
setT0: ;TIMER0OVF через r20 : r19 мс
 	ser r16
	sub r16, r19 
	mov r22, r20
	out TCNT0, r16
	ret
	
output_russian:
	clr r2
	ldi ZH, high(russiantree << 1)
	ldi ZL, low(russiantree << 1)
	mov r1, r18
	rsub_loop:
		lpm r0, Z+
		dec r1
		brne rsub_loop
	lpm
	out PORTA, r0
	ret
output_english:
	clr r2
	ldi ZH, high(englishtree << 1)
	ldi ZL, low(englishtree << 1)
	mov r1, r18
	esub_loop:
		lpm r0, Z+
		dec r1
		brne esub_loop
	lpm
	out PORTA, r0
	ret
russiantree:
.db $00, $01, $11, $1e, $14, $0c, $19, $18, $1e, $1f, $1e, $0e, $10, $16, $0f, $1a
.db $21, $12, $20, $2a, $17, $2b, $1b, $15, $0d, $28, $22, $27, $13, $25, $23, $24
.db $06, $05, $3b, $04, $3b, $3b, $3b, $03, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $02
.db $07, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $08, $3b, $3b, $26, $09, $3b, $0a, $0b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b

englishtree:
.db $00, $01, $11, $1e, $2f, $0c, $32, $18, $34, $35, $1e, $0e, $10, $16, $0f, $1a
.db $21, $12, $20, $2a, $17, $2b, $1b, $15, $0d, $33, $22, $27, $13, $25, $23, $24
.db $06, $05, $3b, $04, $3b, $3b, $3b, $03, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $02
.db $07, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $08, $3b, $3b, $3b, $09, $3b, $0a, $0b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
.db $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b, $3b
