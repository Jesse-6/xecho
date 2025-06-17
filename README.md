# xecho

A simple echo utility, which outputs to stdout (or > FILE) in binary form (which means that any byte can be written, even NULL (\0)), that allows escape sequences.
Supported escape sequences are: \\", \\', \\NNN (octal), \\?, \Uxxxxxxxx (UTF-32), \\\\, \\a, \\b, \\e, \\f, \\n, \\r, \\t, \\uxxxx (UTF-16), \\v, \\xHH (hex byte).
Its code was made to be easily adapted to 32-bit, if one needs to do a 32-bit version of it. This version is 64-bit.

To build it from source code, it has 2 dependencies:

  - fasm2 assembler;
  - fastcall_v1 macro toolkit.

The latter can be found at my GitHub page.
After having fasm2 and fastcall_v1 setted up, compile with: `fasm2 xecho.asm`, then copy the executable file to the binary path of your preference (i.e., `/usr/bin` or `~/.local/bin`). The provided `install.sh` running as super user installs to the `/usr/bin` path.

Tips:

  - use single quotes ('string to be echoed') whenever possible;
  - xecho command without parameters shows the help;
  - xecho "\`command\`\n" to echo command output.

Note: this command works quite similar to the standard `echo -ne` command. It differs on octals (here, they're handled exactly like C-style, according to many docs I read online, not demanding it to begin with \\0 to be an octal) and, depending on the O.S. implementation of echo, the added support for UTF-16 and UTF-32 escaping.

 * This README.md file was made using 'xecho' command.
