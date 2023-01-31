#!/usr/bin/env python3
#prepare: pdftk comp.pdf output uncomp.pdf uncompress
import sys, pathlib, re
in_pdf = pathlib.Path(sys.argv[1]).read_bytes()
out_pdf, count_sub = re.subn(rb'''Length 406.*?\nendstream''',b'''Length 0
>>
stream
endstream
''', in_pdf, flags=re.DOTALL)
pathlib.Path(sys.argv[1]+"watermoved.pdf").write_bytes(out_pdf)
# use a print cycle to remove metadata

