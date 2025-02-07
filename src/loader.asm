                device zxspectrum48

                org 0x5ccb

basic_start equ $

B_RANDOMIZE equ 0f9h
B_USR equ 0c0h
B_VAL equ 0b0h

line10:
                db 0, 10
                dw .len
.cmds                
                db B_RANDOMIZE, B_USR, B_VAL, '"23774":'

.len equ $ - .cmds

                db 0, 15 ; line 15, all the code will be stored in this basic line
                dw End - Start
Start:
                xor a
                out (254), a
                ld  hl, Image_end ; reverse unpacking
                ld  de, 0x4000+6912 
                call ue2_unpack

                di
                halt

ue2_unpack:
                ld b,0                             ; Ideally, these values should be "reused"
                ld a,%10000000     ; e.g. by aligning the addresses.

MainLoop        ld c,1
                call ReadBit                         ; Literal?
                jr c,CopyBytes

EliasGamma      call ReadBit
                rl c
                ret  c                               ; Option to include the end of stream marker.
                call ReadBit
                jr c,EliasGamma

                push hl
                ld l,(hl)
                ld h,b
                add hl,de
                inc hl
CopyBytes       lddr
                jr c,MainLoop
                pop hl
                dec hl
                jr MainLoop

ReadBit         add a,a
                ret nz
                ld a,(hl)
                dec hl
                rla
                ret 

Image:                
                incbin "build/loading.pck"
Image_end: equ $-1

End equ $

    display "Saving moo.tap"
    emptytap "moo.tap"
    savetap  "moo.tap", basic, "MoonRn", basic_start, End - basic_start, 10
