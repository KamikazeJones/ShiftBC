# Befehl `L` – Schreibe LDA-Opcode in den Codepuffer

## Beschreibung

Der Befehl `L` generiert im Codepuffer einen LDA-absolute-Befehl.  
Es werden drei Bytes geschrieben:

1. Der Opcode für LDA absolute (`$AD`)
2. Das Low-Byte der Zieladresse
3. Das High-Byte der Zieladresse

Danach wird der Codezeiger entsprechend um drei erhöht.

## Eingaben

- `p`: Zeiger auf die aktuelle Position im Codepuffer (Low- und High-Byte)
- `s0`: Low-Byte der Adresse, die geladen werden soll
- `s1`: High-Byte der Adresse, die geladen werden soll

## 6502-Assembler-Code

```assembly
;--------------------------------------------------------
; cmd: L
; Schreibe LDA absolut an die aktuelle Codepuffer-Position (p)
; und erhöhe den Codezeiger um 3 Bytes.
;--------------------------------------------------------
L:
    lda #$ad         ; Opcode für LDA absolut
    ldy #$00
    sta (p),y        ; Opcode an p schreiben
    iny
    lda s0
    sta (p),y        ; Low-Byte der Adresse an p+1 schreiben
    iny
    lda s1
    sta (p),y        ; High-Byte der Adresse an p+2 schreiben

    lda #$03
    jsr ADD_P        ; Codezeiger p um 3 erhöhen

    rts
```

## Hinweise

- Die verwendete Hilfsroutine `ADD_P` erhöht den Codezeiger um die gewünschte Byte-Anzahl.
- Diese Routine geht davon aus, dass `p`, `s0` und `s1` im Zero-Page-Bereich definiert sind.
