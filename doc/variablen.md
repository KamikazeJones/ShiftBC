# Zero-Page-Variablen und Register

In diesem Dokument werden die im Projekt verwendeten Zero-Page-Variablen und Register erläutert.

## Übersicht der Variablen und Adressen

| Name  | Adresse    | Zweck                | Beschreibung |
|-------|------------|----------------------|--------------|
| `p`   | $03/$04    | Codezeiger           | Zeigt auf die aktuelle Schreibposition im Codepuffer. Besteht aus zwei aufeinanderfolgenden Bytes: $03 (Low-Byte), $04 (High-Byte). |
| `s0`  | $FB        | Schieberegister 0    | Wird als Low-Byte für Adressoperationen verwendet. Teil des Schieberegisters für Datenmanipulation. |
| `s1`  | $FC        | Schieberegister 1    | Wird als High-Byte für Adressoperationen verwendet. Teil des Schieberegisters für Datenmanipulation. |
| `s2`  | $FD        | Schieberegister 2    | Erweiterung des Schieberegisters – kann für weitere Operationen oder temporäre Werte genutzt werden. |
| `s3`  | $FE        | Schieberegister 3    | Erweiterung des Schieberegisters – kann für weitere Operationen oder temporäre Werte genutzt werden. |

---

## Detaillierte Beschreibung

### p (Codezeiger)
- **Adresse:** $03 (Low-Byte), $04 (High-Byte)
- **Typ:** 16-Bit
- **Verwendung:** Gibt die aktuelle Position im Codepuffer an, an der neue Opcodes oder Daten geschrieben werden sollen.
- **Typische Operationen:** Erhöhen um eine Byte-Anzahl nach jedem Schreibvorgang.

### s0, s1, s2, s3 (Schieberegister)
- **Adressen:**  
  - `s0` = $FB  
  - `s1` = $FC  
  - `s2` = $FD  
  - `s3` = $FE
- **Typ:** 8-Bit je Register
- **Verwendung:** Temporäre Speicherung von Bytes für Adressberechnung, Datenmanipulation oder als Parameter für Befehle.
    - `s0` und `s1` werden oft als Low-/High-Byte einer Adresse eingesetzt.
    - `s2` und `s3` dienen als Zusatzregister für komplexere Operationen.

---

## Hinweis: JSR-$0000-Trick mit den Speicherzellen $00, $01, $02

### Zweck
Die Speicherzellen $00, $01 und $02 werden für einen Trick verwendet, bei dem ein indirekter Sprung durch gezielte Manipulation des Speichers erfolgt.

### Funktionsweise

1. In $00 wird der Opcode $4C (JMP) geschrieben.
2. In $01 und $02 wird das Low- bzw. High-Byte des gewünschten Sprungziels gespeichert.
3. Mit `JSR $0000` wird die Routine angesprungen. Da an Adresse $0000 jetzt ein JMP-Opcode steht, führt der Prozessor den Sprung zu der in $01/$02 hinterlegten Adresse aus.

#### Beispiel

```assembly
; Zieladresse vorbereiten
LDA #$4C        ; Opcode für JMP
STA $00
LDA #<ZIEL
STA $01
LDA #>ZIEL
STA $02

JSR $0000       ; führt tatsächlich einen JMP ZIEL aus
```

- Der Trick nutzt aus, dass der 6502 beim JSR den Rücksprung auf den Stack legt, aber an $0000 tatsächlich ein JMP steht.

---

*Hinweis: Alle genannten Variablen befinden sich im Zero-Page-Bereich ($00xx), um schnelle Zugriffe zu ermöglichen.*
