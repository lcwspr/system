[org 0x7c00]

; 设置屏幕模式为文本模式, 清除屏幕
mov ax, 3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; 0xb800 文本显示器的内存区域
; mov ax, 0xb800
; mov ds, ax
; mov byte [0], 'H'

xchg bx, bx ; 魔术断点
mov si, booting
call print

;阻塞
jmp $

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

booting:
    db "Booting os...", 10, 13, 0

; 填充 0
times 510 - ($ - $$) db 0

; 主引导扇区的最后两个字节必须是这个
db 0x55, 0xaa
