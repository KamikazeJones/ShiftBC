
SR0=$FB
SR1=$FC
SR2=$FD
SR3=$FE
BYTECODE_LOW=$01
BYTECODE_HIGH=$02

interpreter_loop:
        ; Lade nächstes Byte aus dem Bytecode
        LDY #0
        LDA (BYTECODE_LOW),Y ; Lade Byte von Adresse BYTECODE_LOW/BYTECODE_HIGH
        ; Inkrementiere die Adresse direkt (BYTECODE_LOW und BYTECODE_HIGH)
        INC BYTECODE_LOW      ; Low-Byte hochzählen
        BNE skip_high_inc     ; Kein Überlauf → High-Byte bleibt unverändert
        INC BYTECODE_HIGH     ; High-Byte hochzählen (bei Überlauf des Low-Bytes)
skip_high_inc:

        ; Prüfe, ob es eine Hexziffer ist
        JSR asciiToNibble     ; Prüft, ob A eine Hexziffer ist
        BCS continue_opcode   ; Wenn ungültig (Carry = 0), überspringe

        ; Hexziffer → Nibble in Schieberegister verschieben
        JSR ShiftInNibble     ; schiebt das Nibble ins Schieberegister

        ; Springe zur nächsten Iteration
        RTS                   ; Rücksprung zur Schleife

continue_opcode:
        ; Prüfe auf +
        CMP #'+'
        BEQ op_add
        CMP #'-'
        BEQ op_sub
        CMP #'@'
        BEQ op_load
        CMP #'?'
        BEQ op_jumpzero
        CMP #'!'
        BEQ op_store

        ; Unbekannter Opcode → Weiter zur nächsten Iteration
        RTS                   ; Rücksprung zur Schleife

; -------------------------------------------------
; Addition: S1 = S1 + S2 → Ergebnis in SR0/SR1
op_add:
        CLC
        LDA SR0          ; Low SR0 + SR2
        ADC SR2
        STA SR0
        LDA SR1          ; High SR1 + SR3 + evtl. Carry
        ADC SR3
        STA SR1
        RTS              ; Rücksprung zu loop_entry

; -------------------------------------------------
; Subtraktion: S1 = S1 - S2 → Ergebnis in SR0/SR1
op_sub:
        SEC
        LDA SR0
        SBC SR2
        STA SR0
        LDA SR1
        SBC SR3
        STA SR1
        RTS              ; Rücksprung zu loop_entry

; -------------------------------------------------
; @ = lade Wert aus Adresse SR1:SR0 → Ergebnis in SR0/SR1
op_load:
        LDY #0
        LDA (SR0),Y     ; Low-Byte laden
        TAX             ; Im X-Register sichern
        INY
        LDA (SR0),Y     ; High-Byte laden
        STA SR1         ; Zuerst High-Byte speichern
        TXA             ; Low-Byte aus X-Register holen
        STA SR0         ; Dann Low-Byte speichern
        RTS             ; Rücksprung zur Schleife

; -------------------------------------------------
; ! = speichere Wert aus SR2:SR3 an Adresse SR0:SR1
op_store:
        LDY #0           ; Y-Register auf 0 setzen (Offset für indirektes Speichern)
        LDA SR2          ; Lade Low-Byte aus SR2
        STA (SR0),Y      ; Speichere Low-Byte an Adresse SR0:SR1
        INY              ; Y erhöhen, um High-Byte zu speichern
        LDA SR3          ; Lade High-Byte aus SR3
        STA (SR0),Y      ; Speichere High-Byte an Adresse SR0:SR1 + 1
        RTS              ; Rücksprung zur Schleife

; -------------------------------------------------
; op_jumpzero: Springt zu SR0:SR1, wenn SR2:SR3 == 0
op_jumpzero:
        ; Prüfe, ob SR2 und SR3 gleich 0 sind
        LDA SR2          ; Lade den Wert von SR2
        ORA SR3          ; Oder mit dem Wert von SR3
        BEQ jump         ; Wenn beide 0 sind, springe zu SR0:SR1

        ; Nichts tun, wenn SR2:SR3 != 0
        RTS              ; Rücksprung zur Schleife

jump:
        ; Setze BYTECODE_LOW und BYTECODE_HIGH auf SR0 und SR1
        LDA SR0          ; Lade Low-Byte der Zieladresse
        STA BYTECODE_LOW ; Speichere es in BYTECODE_LOW ($01)
        LDA SR1          ; Lade High-Byte der Zieladresse
        STA BYTECODE_HIGH ; Speichere es in BYTECODE_HIGH ($02)
        RTS              ; Rücksprung zur Schleife

; ----------------------------------------
; Erwartet:
;   A = Nibble (Wert 0–15)
; Verändert:
;   A, X, SR0–SR3
; ----------------------------------------

ShiftInNibble:
    ; 4× Bitverschiebung über Carry (ASL + ROL-Kette)
    LDX #4
.shiftLoop:
    ASL SR0    ; SR0 Bit 7 → C, SR0 <<= 1, Bit 0 = 0
    ROL SR1    ; C → SR1 Bit 0, SR1 <<= 1, Bit 7 → C
    ROL SR2
    ROL SR3
    DEX
    BNE .shiftLoop

    ; Neues Nibble in unterstes Nibble von SR0 einfügen
    AND #$0F       ; A = nur untere 4 Bit
    ORA SR0        ; neue unteren 4 Bit setzen, obere bleiben erhalten
    STA SR0
    RTS

; Erwartet: ASCII-Zeichen in A
; Rückgabe: Nibble-Wert (0–15) in A
; Bei ungültigem Zeichen: setzt Carry = 0, A bleibt undefiniert

asciiToNibble:
    CMP #'0'           ; Ist A < '0'?
    BCC notHex         ; Nein → ungültig

    CMP #'9'+1         ; A > '9'?
    BCC isDigit        ; Wenn nicht → es ist Ziffer

    CMP #'a'           ; Ist A < 'a'?
    BCC notHex         ; Nein → ungültig

    CMP #'f'+1         ; A > 'f'?
    BCS notHex         ; Ja → ungültig

    ; A ist zwischen 'a' und 'f'
    SEC                ; Setze das Carry-Flag
    SBC #'a' - 10      ; A := A - ('a' - 10)
    RTS

isDigit:
    SEC                ; Setze das Carry-Flag
    SBC #'0'           ; A := A - '0' (Ziffer zu Zahl)
    RTS

notHex:
    CLC                ; Fehler – kein gültiges Hex-Zeichen
    RTS