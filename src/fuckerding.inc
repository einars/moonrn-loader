effect_delay equ 6

load:           
                exx
                ld hl, lines_reloc
                ld b, effect_delay
                ld c, effect_delay
                exx

                inc d
                ex af, af
                dec d
                di
                in a, (254)
                rra
                and 0x20
                or 2
                ld c, a
                cp a

ld_break        ret nz
ld_start        
                call rom_ld_edge_1
                jr nc, ld_break

                ld hl, 0x415
ld_wait         djnz ld_wait
                dec hl
                ld a, h
                or l
                jr nz, ld_wait

                call rom_ld_edge_2
                jr nc, ld_break

ld_leader
                ld b, 0x9c
                call rom_ld_edge_2
                jr nc, ld_break

                ld a, 0xc6
                cp b
                jr nc, ld_start

                inc h
                jr nz, ld_leader


ld_sync         ld b, 0xc9
                call rom_ld_edge_1
                jr nc, ld_break

                ld a, b
                cp 0xd4
                jr nc, ld_sync
                call rom_ld_edge_1
                ret nc

                ; use black screen, as the rom routines mangled it
                xor a
                out (254), a

                ld h, 0
                ld b, 0xb0

                jr ld_marker

ld_loop         ex af, af
                jr nz, ld_flag

                ld (ix), l
                jr ld_next

ld_flag         
                ; handle flag without any checking
                xor a  ; af' = Z, flag checked
                jr 2f

ld_next
                inc ix
ld_dec          dec de
2
                ex af, af

                ld b, 0xb2
ld_marker       ld l, 1
ld_8_bits       
rel2+*          call ld_edge_2
                ret nc
                ld a, 0xc5
                cp b
                rl l
                ld b, 0xb0
                jp nc, ld_8_bits

                ld a, h
                xor l
                ld h, a

                ld a, d
                or e
                jr nz, ld_loop

                ret

rom_ld_edge_2 equ 0x5e3
rom_ld_edge_1 equ 0x5e7

ld_edge_2
rel1+*:         call ld_edge_1
                ret nc
;breakpoint equ $-load + loader_base
ld_edge_1       
                exx             
                nop

                dec b           ; 4 
                jr z, do_effect ;12/7 jump = +16

                ; 4 + 7 + extra jr 12 = 23

                nop
                nop 
                ; =31

                nop
                exx  ; exx nop nop exx = 16
                ld a, 0x16 - 1 - 2
                jr spin

do_effect       ; + 16 from above
 
                ld b, c         ; 4 ; timing constant

                ; 20 so far

                ld e, (hl)      ; 7
                inc hl          ; 6
                ld d, (hl)      ; 7
                inc hl          ; 6
                ex de, hl       ; 4
                rlc (hl)         ; 15 ; contended memory thou
                ex de, hl       ; 4
                ; 53


                ld e, (hl)      ; 7
                inc hl          ; 6
                ld d, (hl)      ; 7
                inc hl          ; 6
                ex de, hl       ; 4
                rrc (hl)         ; 15 ; contended memory thou
                ex de, hl       ; 4
                ; 53


                xor a
                or d            ; 4
                ; -- 126

                ; adjusted: 12+7+10 = 29 either way
                jr nz, ok    ; 12/7
                ld hl, lines_reloc ; 10
ok:             jr z, adj    ; 12/7 symmetric branch timing adjustment
                ld de, lines_reloc ; 10
adj:
                ; -- + 29 = 155
                nop
                ; 159, ~16*10

                nop
                exx  ; exx nop nop exx = 16

                ld a, 0x16 - 1 - 10

spin:           dec a           ; ~358 T
                jr nz, spin     ; 1 dec-loop = 16T 
                and a

ld_sample       inc b
                ret z

                ld a, 0x7f
                in a, (0xfe)
                rra
                ret nc

                xor c
                and 0x20
                jr z, ld_sample

                ld a, c
                cpl 
                ld c, a

                ;and 7 ; 4
                ;or 8 ; 4
                ;out (0xfe), a ; 11

                nop
                nop
                nop
                nop
                nop

                scf
                ret

lines_reloc equ $ - load + loader_base
lines:
                lua allpass
                local line1 = 0x49e0
                local line2 = line1 + 512
                local line3 = line2 + 512

                sj.add_word(line2 + 16)
                sj.add_word(line3 + 16)

                for i = 1, 15, 1
                do
                  sj.add_word(line1 + 16 - i)
                  sj.add_word(line1 + 16 + i)
                  sj.add_word(line2 + 16 - i)
                  sj.add_word(line2 + 16 + i)
                  sj.add_word(line3 + 16 - i)
                  sj.add_word(line3 + 16 + i)
                end
                endlua
                dw 0
                dw 0



