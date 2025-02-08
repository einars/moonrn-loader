load:           
                inc d
                ex af, af
                dec d
                di
                ld a, 0x0f
                out (254), a
                in a, (254)
                rra
                and 0x20
                or 2
                ld c, a
                cp a

ld_break        ret nz
ld_start        call ld_edge_1
                jr nc, ld_break

                ld hl, 0x415
ld_wait         djnz ld_wait
                dec hl
                ld a, h
                or l
                jr nz, ld_wait

                call ld_edge_2
                jr nc, ld_break

ld_leader
                ld b, 0x9c
                call ld_edge_2
                jr nc, ld_break

                ld a, 0xc6
                cp b
                jr nc, ld_start

                inc h
                jr nz, ld_leader


ld_sync         ld b, 0xc9
                call ld_edge_1
                jr nc, ld_break

                ld a, b
                cp 0xd4
                jr nc, ld_sync
                call ld_edge_1
                ret nc

                ld a, c
                xor 3
                ld c, a
                ld h, 0
                ld b, 0xb0

                jr ld_marker

ld_loop         ex af, af
                jr nz, ld_flag
                jr nc, ld_verify
                ld (ix), l
                jr ld_next

ld_flag         rl c
                xor l
                ret nz
                ld a, c
                rra
                ld c, a
                inc de
                jr ld_dec
ld_verify       ld a, (ix)
                xor l
                ret nz

ld_next
                inc ix
ld_dec          dec de
                ex af, af

                ld b, 0xb2
ld_marker       ld l, 1
ld_8_bits       call ld_edge_2
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

                ld a, h
                cp 1
                ret

ld_edge_2 equ 0x5e3
ld_edge_1 equ 0x5e7

xld_edge_2       call ld_edge_1
                ret nc
xld_edge_1       ld a, 0x16
ld_delay        dec a           ; 358 tstates
                jr nz, ld_delay
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
                and 7
                or 8
                out (0xfe), a
                scf
                ret
