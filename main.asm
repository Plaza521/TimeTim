format PE Console
entry start
include 'win32a.inc'

section '.data' data readable writeable
	out_string db '\r\t%c%c:%c%c:%c%c'
	StdOut dd 0

	_st SYSTEMTIME

	time_msg:
	db "00:00:00"
	time_msg_size = $ - time_msg 
	time_msg_len dd 0


	tm0 = ('0'+(_st.wMinute mod 10))
	tm1 = ('0'+(_st.wMinute / 10))
	ts0 = ('0'+(_st.wSecond mod 10))
	ts1 = ('0'+(_st.wSecond / 10))

	; _t = %t

	; _t_s =  _t mod 60
	; _t_m = ((_t - _t_s) / 60) mod 60
	; _t_h = (((_t - (_t_m * 60) - _t_s) / 3600) + 3) mod 24

section '.code' code readable writeable executable

start:

	;push _st
	;call [GetLocalTime]
	; _t = _st

	; _t_s =  _t mod 60
	; _t_m = ((_t - _t_s) / 60) mod 60
	; _t_h = (((_t - (_t_m * 60) - _t_s) / 3600) + 3) mod 24

	stdcall [GetLocalTime], _st

	stdcall [GetStdHandle], STD_OUTPUT_HANDLE
	mov [StdOut], eax 

	call Fmat

	stdcall [WriteFile], [StdOut], time_msg, time_msg_size, time_msg_len, 0

	stdcall [ExitProcess], 0

	Fmat:
		mov ax, [_st.wHour]
		mov edi, time_msg + 1
		call .ascii

		mov ax, [_st.wMinute]
		mov edi, time_msg + 4
		call .ascii

		mov ax, [_st.wSecond]
		mov edi, time_msg + 7
		call .ascii
		ret 

	.ascii:
		std
		cmp ax, 10
		jl .onex10

		and ah, ah
		jz .twox16

		mov bh, 10
		div bh
		or ah, 0x30
		mov [edi], ah
		dec edi
		.twox16:
		aam
		or al, 0x30
		stosb
		mov al, ah
		cmp ah, 9
		jg .twox16
		.onex10:
		or al, 0x30
		stosb
		cld
	ret 

section '.idata' data import readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
  import kernel,  				ExitProcess, 'ExitProcess', GetLocalTime, 'GetLocalTime', GetModuleName, 'GetModuleName', GetStdHandle, 'GetStdHandle', WriteFile, 'WriteFile'
  import msvcrt,  				printf, 'printf'
