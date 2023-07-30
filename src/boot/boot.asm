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

mov edi, 0x1000 ; 读取的目标内存
mov ecx, 0  ; 起始扇区
mov bl, 1   ; 扇区数量
call read_disk

;阻塞
jmp $

read_disk:

    ; 设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx      ; 0x1f3
    mov al, cl  ; 起始扇区的前8位
    out dx, al

    inc dx      ; 0x1f4
    shr ecx, 8
    mov al, cl  ; 起始扇区的中8位
    out dx, al

    
    inc dx      ; 0x1f5
    shr ecx, 8
    mov al, cl  ; 起始扇区的中8位
    out dx, al

    inc dx      ; 0x1f6
    shr ecx, 8
    and cl, 0b1111  ;高四位置零
    
    mov al, 0b1110_0000;
    or al, cl
    out dx, al      ; 主盘 LBA 模式

    inc dx     ; 0x1f7
    mov al, 0x20    ; 读硬盘
    out dx, al

    ; 清空
    xor ecx, ecx;
    ; mov ecx, 0  上面好

    mov cl, bl  ; 得到读写扇区的数量

    .read:
        push cx             ; 保存 cx
        call .waits
        call reads          ; 读取一个扇区
        pop cx
        loop .read
    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2         ; 直接调整下一行 nop 
            jmp $+2
            jmp $+2

            and al, 0b1000_1000
            cmp al, 0b1000_1000
            jnz .check
        ret
    
    .reads:
        mov dx, 0x1f0
        mov cx, 256         ; 一个扇区 256
        .readw
            in ax, dx
            jmp $+2         ; 直接调整下一行 nop 
            jmp $+2         ; 直接调整下一行 nop 
            jmp $+2         ; 直接调整下一行 nop 
            mov [edi], ax
            add edi, 2
            loop .readw
        ret

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
