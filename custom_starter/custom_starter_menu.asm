; GetStarterOptionPointer.Pointers indexes
	const_def
	const OPT_STARTER_SPECIES ; 0
	const OPT_STARTER_ATK_DV  ; 1
	const OPT_STARTER_DEF_DV  ; 2
	const OPT_STARTER_SPE_DV  ; 3
	const OPT_STARTER_SPC_DV  ; 4
	const OPT_STARTER_BALL    ; 5
	const OPT_STARTER_CANCEL  ; 6
NUM_STARTER_OPTIONS EQU const_value   ; 7

CustomStarterMenu:
	;store current WRAM bank
	ldh a, [rSVBK]
	push af
	
	;force WRAM bank 1
	ld a, 1
	ld [rSVBK], a

	ld hl, hInMenu
	ld a, [hl]
	push af
	ld [hl], TRUE;FALSE ;TRUE
	call ClearBGPalettes
	hlcoord 0, 0
	ld b, SCREEN_HEIGHT - 2
	ld c, SCREEN_WIDTH - 2
	call Textbox
	hlcoord 1, 2
	ld de, StringCustomStarterOptions
	call PlaceString
	xor a
	ld [wJumptableIndex], a

; display the settings of each option when the menu is opened
	ld c, NUM_STARTER_OPTIONS - 2 ; omit frame type, the last option
.print_text_loop
	push bc
	xor a
	ldh [hJoyLast], a
	call GetStarterOptionPointer
	pop bc
	ld hl, wJumptableIndex
	inc [hl]
	dec c
	jr nz, .print_text_loop

	xor a
	ld [wJumptableIndex], a
	inc a
	ldh [hBGMapMode], a
	call WaitBGMap
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call SetPalettes

.joypad_loop
	call JoyTextDelay
	ldh a, [hJoyPressed]
	and START | B_BUTTON
	jp nz, ExitStarterOptions
	call OptionsStarterControl
	jr c, .dpad
	call GetStarterOptionPointer
	jp c, ExitStarterOptions

.dpad
	call Options_StarterUpdateCursorPosition
	ld c, 3
	call DelayFrames
	jr .joypad_loop

ExitStarterOptions:
	; set starters
	ld a, CYNDAQUIL
	ld [wCustomStarter1], a
	ld a, TOTODILE
	ld [wCustomStarter2], a
	ld a, CHIKORITA
	ld [wCustomStarter3], a
	
	ld a, [wCustomStarterPosition]
	ld hl, wCustomStarter1
	bit STARTER_POS_LEFT, a
	jr nz, .done
	inc hl
	bit STARTER_POS_MID, a
	jr nz, .done
	inc hl
.done
	ld a, [wCustomStarterDexID]
	ld [hl], a
	
	pop af
	ldh [hInMenu], a
	
	;restore previous WRAM bank
	pop af
	ld [rSVBK], a
	
	ret

StringCustomStarterOptions:
	db "STARTER SPECIES<LF>"
	db "                 <LF>" ; Species placeholder
	db "HOLD L/R : FASTER<LF>"
	db "<LF>"
	db "STARTER DVS<LF>"
	db " ATK:<LF>"
	db " DEF:<LF>"
	db " SPD:<LF>"
	db " SPC:<LF>"
	db "                 <LF>" ; Hidden Power placeholder 
	db "<LF>"
	db "STARTER BALL<LF>"
	db " LEFT  MID  RIGHT<LF>"
	db "<LF>"
	db " CANCEL@"

GetStarterOptionPointer:
	jumptable .Pointers, wJumptableIndex

.Pointers:
; entries correspond to OPT_* constants
	dw Options_StarterSpecies
	dw Options_StarterAtkDV
	dw Options_StarterDefDV
	dw Options_StarterSpeDV
	dw Options_StarterSpcDV
	dw Options_StarterBall
	dw Options_StarterCancel

Options_StarterSpecies:
	ld a, [wCustomStarterAlphabeticalID]
	ld c, a
	ldh a, [hJoyDown]
	bit D_LEFT_F, a
	jr nz, .Decrease
	bit D_RIGHT_F, a
	jr z, .NonePressed
	jr .Increase ; right pressed

.Increase:
	inc c
	ld a, c
	cp NUM_POKEMON
	jr nz, .Save ; valid 0-250 offset
	ld c, 0 ; overflow fix
	jr .Save

.Decrease:
	ld a, c
	and a
	jp nz, .NoUnderflow ; valid 1-250 offset
	ld c, NUM_POKEMON - 1 ; underflow fix
	jr .Save
	
.NoUnderflow:
	dec c 
	; fallthrough

.Save:
	ld a, c
	ld [wCustomStarterAlphabeticalID], a
	;fallthrough
	

.NonePressed: ; display name
	hlcoord 3, 3
	ld de, StringEmptyName
	call PlaceString
	
	call SetCustomStarterIDs
	ld a, [wCustomStarterDexID]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ld de, wStringBuffer1
	hlcoord 3, 3
	call PlaceString
	and a
	ret
	
StringEmptyName:
	db "          @"


Options_StarterAtkDV:
	ld hl, wCustomStarterAtkDV
	ld a, [hl]
	jp DVsCheckJoy
	
Options_StarterDefDV:
	ld hl, wCustomStarterDefDV
	ld a, [hl]
	jp DVsCheckJoy
	
Options_StarterSpeDV:
	ld hl, wCustomStarterSpeDV
	ld a, [hl]
	jp DVsCheckJoy
	
Options_StarterSpcDV:
	ld hl, wCustomStarterSpcDV
	ld a, [hl]
	jp DVsCheckJoy
	
DVsCheckJoy:
	ld b, a ; store backup DV
	ldh a, [hJoyPressed]
	bit D_LEFT_F, a
	jr nz, .TryDecrease
	bit D_RIGHT_F, a
	jr z, .NonePressed
	jr .TryIncrease ; right pressed

.TryIncrease:
	ld a, b
	cp $f
	jr nc, .Pressed ; 15 reached
	inc a
	jr .Pressed

.TryDecrease
	ld a, b
	cp $0
	jr z, .Pressed ; 0 reached
	dec a
	
.Pressed:
	ld [hl], a
	jr .Display
	
.NonePressed:
.Display:
	hlcoord 7, 7
	ld de, wCustomStarterAtkDV
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	hlcoord 7, 8
	ld de, wCustomStarterDefDV
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	hlcoord 7, 9
	ld de, wCustomStarterSpeDV
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	hlcoord 7, 10
	ld de, wCustomStarterSpcDV
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	
	jr .CalculateHiddenPower

.CalculateHiddenPower
	ld hl, wCustomStarterAtkDV
	; Power:

; Take the top bit from each stat

	; Attack
	ld a, [hli]
	and %1000

	; Defense
	ld b, a
	ld a, [hli]
	and %1000
	srl a
	or b

	; Speed
	ld b, a
	ld a, [hli]
	and %1000
	srl a
	srl a
	or b

	; Special
	ld b, a
	ld a, [hl]
	and %1000
	srl a
	srl a
	srl a
	or b

; Multiply by 5
	ld b, a
	add a
	add a
	add b

; Add Special & 3
	ld b, a
	ld a, [hld]
	and %0011
	add b

; Divide by 2 and add 30 + 1
	srl a
	add 30
	inc a

	ld [wCustomStarterHiddenPowerBP], a

; Type:

	; Def & 3
	ld a, [hld]
	ld a, [hld]
	and %0011
	ld b, a

	; + (Atk & 3) << 2
	ld a, [hl]
	and %0011
	add a
	add a
	or b

; Skip Normal
	inc a

; Skip Bird
	cp BIRD
	jr c, .done
	inc a

; Skip unused types
	cp UNUSED_TYPES
	jr c, .done
	add SPECIAL - UNUSED_TYPES

.done
	ld [wCustomStarterHiddenPowerTypeID], a
	ld [wNamedObjectIndexBuffer], a

.DisplayHiddenPower
	hlcoord 3, 11
	ld de, StringEmptyName
	call PlaceString
	
	farcall GetTypeName
	hlcoord 1, 11
	ld de, wStringBuffer1
	call PlaceString
	
	hlcoord 10, 11
	ld de, wCustomStarterHiddenPowerBP
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	
	ret
	

Options_StarterBall:
	ldh a, [hJoyPressed]
	bit D_LEFT_F, a
	jr nz, .LeftPressed
	bit D_RIGHT_F, a
	jr z, .NonePressed
	jr .RightPressed ; right pressed

.LeftPressed:
	ld a, [wCustomStarterPosition]
	bit STARTER_POS_LEFT, a
	jr nz, .Display ; left starter already
	call ClearMovingArrow
	srl a
	ld [wCustomStarterPosition], a
	jr .Display
	
.RightPressed:
	ld a, [wCustomStarterPosition]
	bit STARTER_POS_RIGHT, a
	jr nz, .Display ; right starter already
	call ClearMovingArrow
	sla a
	ld [wCustomStarterPosition], a
	jr .Display
	
.NonePressed:
	;fallthrough
.Display:
	;call Options_StarterUpdateCursorPosition
	ret

ClearMovingArrow:
	push af
	call GetBallOffset
	hlcoord 0, 14
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], " "
	pop af
	ret 

Options_StarterCancel:
	ldh a, [hJoyPressed]
	and A_BUTTON
	jr nz, .Exit
	and a
	ret

.Exit:
	scf
	ret

OptionsStarterControl:
	ld hl, wJumptableIndex
	ldh a, [hJoyLast]
	cp D_DOWN
	jr z, .DownPressed
	cp D_UP
	jr z, .UpPressed
	and a
	ret

.DownPressed:
	ld a, [hl]
	cp OPT_STARTER_CANCEL ; maximum option index
	jr nz, .Increase
	ld [hl], OPT_STARTER_SPECIES ; first option
	scf
	ret

.Increase:
	inc [hl]
	scf
	ret

.UpPressed:
	ld a, [hl]
	cp OPT_STARTER_SPECIES ; first option
	jr nz, .Decrease
	ld [hl], OPT_STARTER_CANCEL
	scf
	ret

.Decrease:
	dec [hl]
	scf
	ret

Options_StarterUpdateCursorPosition:
	hlcoord 1, 3
	call DrawEmptyArrow
	hlcoord 1, 7
	call DrawEmptyArrow
	hlcoord 1, 8
	call DrawEmptyArrow
	hlcoord 1, 9
	call DrawEmptyArrow
	hlcoord 1, 10
	call DrawEmptyArrow
	
	call GetBallOffset
	hlcoord 0, 14
	ld e, a
	ld d, 0
	add hl, de
	call DrawEmptyArrow
	
	hlcoord 1, 16
	call DrawEmptyArrow

.mainCursor
	ld a, [wJumptableIndex]
	cp OPT_STARTER_CANCEL
	jr z, .cancel
	cp OPT_STARTER_BALL
	jr z, .ball
	cp OPT_STARTER_SPC_DV
	jr z, .spc
	cp OPT_STARTER_SPE_DV
	jr z, .spe
	cp OPT_STARTER_DEF_DV
	jr z, .def
	cp OPT_STARTER_ATK_DV
	jr z, .atk
	jr .species
	
.species
	hlcoord 1, 3
	jp DrawFullArrow	
.atk
	hlcoord 1, 7
	jp DrawFullArrow
.def
	hlcoord 1, 8
	jp DrawFullArrow
.spe
	hlcoord 1, 9
	jp DrawFullArrow
.spc
	hlcoord 1, 10
	jp DrawFullArrow
.ball
	hlcoord 0, 14
	call GetBallOffset
	ld e, a
	ld d, 0
	add hl, de
	jp DrawFullArrow
.cancel
	hlcoord 1, 16
	jp DrawFullArrow
	
DrawFullArrow:
	ld [hl], "▶" ; full arrow
	ret
	
DrawEmptyArrow:
	ld [hl], "▷" ; empty arrow
	ret

GetBallOffset:
	ld a, [wCustomStarterPosition]
	bit STARTER_POS_LEFT, a
	jr nz, .left
	bit STARTER_POS_MID, a
	jr nz, .mid
	;fallthrough ;jr .right
.right
	ld a, 12
	jr .done
.mid
	ld a, 7
	jr .done
.left
	ld a, 1
.done
	ret
