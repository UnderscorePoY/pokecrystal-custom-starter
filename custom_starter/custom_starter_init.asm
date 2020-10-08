; wCustomStarterPosition bits
	const_def
	const STARTER_POS_LEFT      ; 0
	const STARTER_POS_MID       ; 1
	const STARTER_POS_RIGHT     ; 2
NUM_STARTER_POS EQU const_value ; 3

; CHANGE
InitCustomStarter:
	;push af
	;push hl

	;store current WRAM bank
	ldh a, [rSVBK]
	push af
	
	;force WRAM bank 1
	ld a, 1
	ld [rSVBK], a
	
	ld a, [wSaveFileExists]
	ld [wDisabledCustomStarterMenu], a

	ld a, $e1 ; Default alphabetical-ordered starter ID ; Totodile
	ld [wCustomStarterAlphabeticalID], a
	ld a, TOTODILE
	ld [wCustomStarterDexID], a
	ld a, $f
	ld hl, wCustomStarterAtkDV
	ld [hli], a ; Atk
	ld [hli], a ; Def
	ld [hli], a ; Spe
	ld [hl], a  ; Spc
	xor a
	set STARTER_POS_MID, a
	ld [wCustomStarterPosition], a
	
	ld a, CYNDAQUIL
	ld [wCustomStarter1], a
	ld a, TOTODILE
	ld [wCustomStarter2], a
	ld a, CHIKORITA
	ld [wCustomStarter3], a

	;restore previous WRAM bank
	pop af
	ld [rSVBK], a

	;pop hl
	;pop af
	ret
	
SetCustomStarterIDs: ; used with WRAM Bank 1 context
	ld a, [wCustomStarterAlphabeticalID]
	ld d, 0
	ld e, a
	ld hl, AlphabeticalPokedexOrder
	add hl, de
	ld a, BANK(AlphabeticalPokedexOrder)
	call GetFarByte ; gets Dex Pokémon ID in a
	ld [wCustomStarterDexID], a
	ret
	
SetDisabledCustomStarterMenu:
	;store current WRAM bank
	ldh a, [rSVBK]
	push af
	
	;force WRAM bank 1
	ld a, 1
	ld [rSVBK], a
	
	ld a, TRUE
	ld [wDisabledCustomStarterMenu], a
	
	;restore previous WRAM bank
	pop af
	ld [rSVBK], a
	
	ret

	
IsDisabledCustomStarterMenu:
	;store current WRAM bank
	ldh a, [rSVBK]
	push af
	
	;force WRAM bank 1
	ld a, 1
	ld [rSVBK], a
	
	ld a, [wDisabledCustomStarterMenu]
	ld c, a

	;restore previous WRAM bank
	pop af
	ld [rSVBK], a
	
	ld a, c
	
	ret