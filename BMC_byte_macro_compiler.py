def debug(msg):
    # print(msg)
    pass

class bmc:
    def __init__(self):
        self.data = []
        self.sourceadr = []
        self.macro = []
        self.source = ""
        self.sourceptr = 0
        self.code = ""
        self.hextoggle = 0
        self.hex = ""

    def parsehex(self, ch):
        if ch >= '0' and ch <= '9' or ch >= 'a' and ch <= 'f':
            self.hex += ch
            self.hextoggle += 1
            if self.hextoggle == 2:
                self.hextoggle = 0
                self.data.append(self.hex)
                self.hex = ""
            return True
        return False

    def expand(self, ch):
        if not self.parsehex(ch):
            if ch == ',':
                x = self.data.pop()
                self.code += x + " "
                debug("expand - write " + x)
            elif ch == ':':
                name = self.source[self.sourceptr+1]
                start = self.sourceptr+2
                self.macro.append((name, start))
                self.sourceptr += 2
                while self.source[self.sourceptr] != ';':
                    self.sourceptr += 1
                macrocode = self.source[start:self.sourceptr+1]
                debug(f"expand - define macro '{name}':{macrocode}")
            elif ch == ';':
                # expand macht nichts weiter!
                pass
            else:
                for c, m in self.macro:
                    if ch == c:
                        self.sourceadr.append(self.sourceptr)
                        self.sourceptr = m
                        debug(f"expand - expand macro {c}, adr={m}")
                        break

    def expansion(self):
        while self.sourceptr < len(self.source):
            ch = self.source[self.sourceptr]
            if ch.strip() == "":
                self.sourceptr += 1
                continue
            debug(f"expansion - {ch}")
            if ch == ';':
                if not self.sourceadr:
                    # fertig mit expansion!
                    break
                else:
                    self.sourceptr = self.sourceadr.pop()
                    self.sourceptr += 1
                    continue
            self.expand(ch)
            self.sourceptr += 1

if __name__ == "__main__":
    b = bmc()
    b.source = """
    :L ad, , , ;
    :S 8d, , , ;
    :T a9, , 85, 05, a9, , 85, 06 ;
    :F b1, 05,;
    :Y c8,;
    :@ T a0, 00, F aa, Y F;

    12 34 L 
    12 34 @ ; """
    b.expansion()
    print(b.code)
