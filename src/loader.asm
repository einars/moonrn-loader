                device zxspectrum128

                org 0x5ccb

basic_start equ $

B_RANDOMIZE equ 0f9h
B_USR equ 0c0h
B_VAL equ 0b0h


target_code_start equ 32768
target_code_len equ 22440
packed_code_base equ Image ; overwrite packed image and all the shit
packed_code_len equ 17730

line10:
                db 0, 10
                dw .len
.cmds                
                db B_RANDOMIZE, B_USR, B_VAL, '"23774":'

.len equ $ - .cmds

                db 0, 15 ; line 15, all the code will be stored in this basic line
                dw End - Start
Start:
                ld sp, 65535
                xor a
                ld (iy+14), a
                out (254), a
                ld  hl, Image_end ; reverse unpacking
                ld  de, 0x4000+6912 - 1

                call ue2_unpack

                ld ix, packed_code_base
                ld de, packed_code_len
                ld a, 255
                scf
                call 0556h

                ld hl, target_code_start
                push hl
                ld de, target_code_start + target_code_len - 1
                ld hl, packed_code_base + packed_code_len - 1


ue2_unpack:
                ld b, 0
                ld a, 128

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
    tapout "moo.tap"
    incbin "build/code.pck"
    tapend
