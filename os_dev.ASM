format binary
org 7c00h
use16

;push print_m mov_cursor get_simbol write_simb get_cursor_pos gra_t  ;� ���� ������ �������


start:;Start or reset
	push dx;��������� ���-�����
	cli
	mov ax,00h
	mov ds,ax      ;��������� ����������, �������� ���, ��������� ����������
	mov es,ax
	mov ss,ax
	sti

	pop dx
	push dx
	mov ah,00h;����������� ����
	int 13h;   ��� ������� ����
	jc int13_err

	mov ax, 0004h ; �������� �����,80�25 �����  ;4
	int 10h

	mov dx,0000h ;��������� �������
	call mov_cursor

	mov bp,greating
	mov cx,24
	call print_m

	mov dx,0100h
	call mov_cursor

;	 mov bp,help_nt
;	 mov cx,20
;	 call print_m

;	 mov dx,0200h
;	 call mov_cursor

	mov bp,kernel_wait
	mov cx,24
	call print_m

writing:
	call get_simbol
	cmp al,08h
	jz back_space_wr
	cmp al,0Dh
	jz enter_wr
       ; cmp al,37
	;jz left_key
	;cmp al,38
	;jz up_key
	;cmp al,40
	;jz down_key
	;cmp al,39
	;jz right_key
	;cmp al,27;Escape
	;jz start;Reset data
	call write_simb
	mov [comnd],al
	jmp writing

print_m:; cx - ����� ������    bp - ����� ;�������� �����
	mov ax,1301h
	mov bh,00h
	mov bl,01h
	int 10h
	ret

mov_cursor:;dh - ������ dl - �������   �������� ������(���������)
	mov ah,02h
	mov bh,0h
	int 10h
	ret

get_cursor_pos:;�������� ������� �������
	mov bh,00h
	;�����:
	;DH - ������
	;DL - �������
	ret

get_simbol:;�������� ������ �� ����������
	;in al,60h
	mov ah,00h
	int 16h
	;AL - ASCII
	ret

write_simb:;�������� ������ � ������� ������� ���������� �������
	mov ah,0eh
	;al - ������
	int 10h
	ret

back_space_wr:;��������� ���������
	mov al,08h
	call write_simb
	mov al,20h
	call write_simb
	mov al,08h
	call write_simb
	;ret
	jmp writing

enter_wr:;��������� ������
	call get_cursor_pos
	inc dh
	call mov_cursor
	;ret
	cmp [comnd],'q'
	jz quit
	cmp [comnd],'n'
	jz load_kernel
	jmp writing

load_kernel:
	mov ah,02h
	pop dx	;
	push dx ;DX - DH � DL ��� �������
	mov ch,00h;������� �������
	mov cl,02h;������ ������(����) �� all_os.asm ���� � 1!
	mov al,01h;1 ������

	mov bx,0000h
	mov es,bx   ;�����, ���� ������ ����(0000h:0500h)
	mov bx,0500h
	int 13h
	jc int13_err

	jmp 0500h;����

int13_err:
	mov cx,13
	mov bp,int13_ert
	call print_m
	jmp writing
quit:
	jmp $

;up_key:;������� �����
;	 call get_cursor_pos
;	 dec dh
;	 call mov_cursor
;	 jmp writing

;down_key:
;	 jmp enter_wr

;left_key:
;	 call get_cursor_pos
;	 dec dl
;	 call mov_cursor
;	 jmp writing

;right_key:
;	 mov al,20h
;	 call write_simb
;	 jmp writing

gra_t:;����������� �����
	mov ah,0Ch
	mov bh,0h
	;dx - ������
	;cx - �������
	;mov al,05h ;AL - ����
	int 10h
	ret

greating db "Hello,kernel! I am OS!..",0h
kernel_wait db "Type 'n' to load kernel!",0h
int13_ert db "Int 13 error!",0h
;enter_i db "You ����� enter",0h
;simb db "a",0h
;help_nt db "Type F1 to get help!",0h
;help db "Type 'q' to shutdown OS. F1 to help and esc to restart OS.",0h
comnd db ?
times (510-($-$$)) db 0
db 055h,0aah;����� ����