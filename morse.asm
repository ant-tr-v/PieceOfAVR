.equ TIMSK = $39
.equ TCCR0 = $33
.equ TCNT0 = $32
.equ PORTA = $1b ;вывод
.equ DDRA = $1a 
.equ PINB = $16 ;ввод
.equ PORTB = $18
.equ DDRB = $17
.equ SPH = $3e
.equ SPL = $3d

.set DOTT = $90 ;время точек и тире в ~ милисекундах все что длиннее - тире  



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
nop
nop
nop
nop
main: ;регистры r16 - для записи чисел в память, r17 - возвращаемое значение функций r18...21-аргументы функций
	rcall checkB ;r2 - регистр режима работы, r3 - регистр состояний. r0, r1, r16 используются функциями на их усмотрение
	clr r17; r31 универсальная глобальная переменная
	clr r16
	loop:
		inc r16
		cpi r16, $10
		brlt loop
	sbrs r4, 0
		rcall B00 ;если низкий уровень на 0 входе порта B
	sbrc r4, 0
		rcall B01 ;если высокий уровень на 0 входе порта B
	out PORTA, r3
	rjmp main 
B00:
	push r2
	mov r16, r2
	cpi r16, $02 
	brge b00end;если мы не считываем код морзянки то выходим из функции
	mov r16, r3
	cpi r16, 0
	brne b00end;если мы уже ждем символ то все ок
		inc r3; в противном случае говорим что ждем точку
		ldi r18, DOTT
		rcall setT0; и ставим таймер
	b00end:
	pop r2
	ret
B01:
	clr r3
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
	out PORTB, r16 ;Включили автоподтягивание
	ldi r16, $01
	out TIMSK, r16; препрывания по переполнению T0
	ldi r16, $05
	out TCCR0, r16
	ldi r16, $02;4 строчки - установка указателя стека
	out SPH, r16
	ldi r16, $5f
	out SPL, r16
	sei
	rjmp main
TIMER0OVF:
	push r2
	mov r16, r2
	cpi r16, $02 
	brge T0Oend;если мы не считываем код морзянки то выходим из функции
	mov r16, r3
	cpi r16, $01
	brne T0Oend
		inc r3 ;теперь тире
	T0Oend:
	pop r2
	reti
setT0: ;TIMER0OVF через r18 мс
 	ser r16
	sub r16, r18 
	out TCNT0, r16
	ret
