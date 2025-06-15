# xecho

A simple echo utility, which outputs to stdout in binary form (which means that any byte can be written, even NULL (\0)), that allows escape sequences.
Supported escape sequences are: \", \47, \nnn (octal), \?, \Uxxxxxxxx (UTF-32), \\, \a, \b, \e, \f, \n, \r, \t, \uxxxx (UTF-16), \v, \xHH (hex byte)
Its code was made to be easily adapted to 32-bit, if one needs to do a 32-bit version of it. This version is 64-bit.

To build it from source code, it has 2 dependencies:

  - fasm2 assembler;
  - fastcall_v1 macro toolkit.

The latter can be found at my GitHub page.
