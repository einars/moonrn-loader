                device zxspectrum128

                org 0x5ccb

basic_start equ $

B_RANDOMIZE equ 0f9h
B_USR equ 0c0h


target_code_start equ 32768

                lua
                local f

                f = io.open("./pristine/moonrn.bin")
                sj.insert_define("target_code_len", f:seek("end"))
                f:close()

                f = io.open("./build/code.pck")
                sj.insert_define("packed_code_len", f:seek("end"))
                f:close()

                endlua

line10:
                db 0, 10
                dw End - .cmds
.cmds
                db B_RANDOMIZE, B_USR, "1", 14, 0, 0
                dw Start
                db 0, ':'

Start:
                ld sp, 65535
                xor a
                ld (iy+14), a
                out (254), a
                ld  hl, Image_end ; reverse unpacking
                ld  de, 0x4000+6912 - 1

                call ue2_unpack

loader_base equ 65000
                ; relocate calls to ld_edge_*
                ;ld hl, ld_edge_1 - load + loader_base
                ;;; ld hl, rom_ld_edge_1
                ;;; ld (p1_0), hl
                ;;; ld (p1_1), hl
                ;;; ld (p1_2), hl
                ;;; ld (p1_3), hl
                ;;; ld hl, rom_ld_edge_2
                ;ld hl, ld_edge_2 - load + loader_base
                ;;; ld (p2_1), hl
                ;;; ld (p2_2), hl
                ;;; ld (p2_3), hl

                ld hl, loader_start
                ld de, loader_base
                ld bc, loader_end - loader_start
                ldir


                ; di
                ; halt


                ld ix, packed_code_start
                ld de, packed_code_len
                ld a, 255
                scf

                ;call 0556h
                call loader_base

                ld hl, target_code_start
                push hl
                ld de, target_code_start + target_code_len - 1
                ld hl, packed_code_start + packed_code_len - 1


ue2_unpack:
                ld a, 128

MainLoop        ld bc,1
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

loader_start:
                include "src/fuckerding.inc"
loader_end equ $

packed_code_start:
                incbin "build/loading.pck"
Image_end equ $-1

End equ $

    display "Saving moo.tap"
    emptytap "moo.tap"
    savetap  "moo.tap", basic, "MoonRn", basic_start, End - basic_start, 10
    tapout "moo.tap"
    incbin "build/code.pck"
    tapend
