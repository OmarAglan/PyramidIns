; Minimal Boot Sector for PyramidIns ISO

[BITS 16]
[ORG 0x7C00]

start:
    ; --- Basic Setup ---
    cli                     ; Disable interrupts
    xor ax, ax              ; AX = 0
    mov ds, ax              ; Data Segment = 0
    mov es, ax              ; Extra Segment = 0
    mov ss, ax              ; Stack Segment = 0
    mov sp, 0x7C00          ; Stack Pointer grows down from boot sector base
    sti                     ; Enable interrupts (though none are handled yet)

    ; --- Load Kernel (Placeholder - assumes kernel at LBA 1) ---
    ; We need to load the kernel from the ISO.
    ; Assume kernel is at LBA 1 (sector 1) and we load, say, 16 sectors.
    ; Kernel destination address: 0x10000 (1MB mark, arbitrary choice)

    mov ah, 0x42            ; Extended Read Sectors
    mov dl, 0x80            ; Drive number (usually 0x80 for first HDD, might vary for CD)
                            ; NOTE: BIOS drive number for CD might be different! This needs refinement.
    mov si, dap             ; Pointer to Disk Address Packet

    int 0x13                ; Call BIOS disk service
    jc load_error           ; Jump if carry flag set (error)

    ; --- Jump to Kernel --- 
    ; Assuming kernel is loaded at 0x10000
    jmp 0x0000:0x10000      ; Far jump to segment 0, offset 0x10000 (effectively 0x10000 linear)

load_error:
    ; Simple error handling: Print 'E' and halt
    mov ah, 0x0E            ; Teletype output function
    mov al, 'E'
    mov bx, 0x0007          ; BH=page 0, BL=white on black
    int 0x10

halt:
    cli
    hlt
    jmp halt

; Disk Address Packet (DAP)
dap:
    db 0x10                 ; Size of packet (16 bytes)
    db 0                    ; Reserved, must be zero
    dw 16                   ; Number of sectors to transfer (16 sectors = 8KB)
    dw 0x0000               ; Destination offset
    dw 0x1000               ; Destination segment (0x1000 * 16 = 0x10000 linear address)
    dd 1                    ; Starting Absolute Block Address (LBA) - Sector 1
    dd 0                    ; LBA (Upper 32 bits - usually 0 for < 2TB)

; --- Boot Sector Padding and Magic Number ---
times 510 - ($-$$) db 0  ; Pad remaining bytes with 0
dw 0xAA55               ; Boot signature 