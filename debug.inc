%if EBUG == 1
	%define DEBUG xchg bx, bx
%elif EBUG == 2
	%define DEBUG int3
%elif EBUG == 3
	%macro DEBUG 0
		xchg bx, bx
		int3
	%endmacro
%elif EBUG == 4
	%define DEBUG jmp $
%else
	%define DEBUG
%endif
