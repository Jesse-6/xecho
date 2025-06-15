format ELF64 executable 3
entry Start

include 'anon_label.inc'
include 'fastcall_v1.inc'
include 'stdio.inc'

define CL_YELLOW 27,'[1;33m'
define CL_ORANGE 27,'[1;38;5;208m'
define CL_GREEN  27,'[1;32m'
define CL_RESET  27,'[0m'

_data                              ;   08   19   2A   3B   4C   5D   6E   7F
     escapetable:                  db 255, 255, '"', 255, 255, 255, 255, "'" ; 20 - 27
                                   db 255, 255, 255, 255, 255, 255, 255, 255 ; 28 - 2F
                                   db 254, 254, 254, 254, 254, 254, 254, 254 ; 30 - 37
                                   db 255, 255, 255, 255, 255, 255, 255, '?' ; 38 - 3F
                                   db 255, 255, 255, 255, 255, 255, 255, 255 ; 40 - 47
                                   db 255, 255, 255, 255, 255, 255, 255, 255 ; 48 - 4F
                                   db 255, 255, 255, 255, 255, 251, 255, 255 ; 50 - 57
                                   db 255, 255, 255, 255, '\', 255, 255, 255 ; 58 - 5F
                                   db 255, 007, 008, 255, 255, 027, 012, 255 ; 60 - 67
                                   db 255, 255, 255, 255, 255, 255, 010, 255 ; 68 - 6F
                                   db 255, 255, 013, 255, 009, 252, 011, 255 ; 70 - 77
                                   db 253, 255, 255, 255, 255, 255, 255, 255 ; 78 - 7F

     helper                        db 'Binary echo utility - version 0.'
                                   file 'version'
                                   db ' - made in assembly with fasm2 assembler.',10
                                   db 'By: Jessé Gonçalves',10
                                   db 'Print to standard output (or > file) a binary string, UTF-8 '
                                   db 'encoded, that could contain any standard (also \e) escape sequence, '
                                   db 'even \0 null char is also printed.',10
                                   db 'As ''binary echo'', it means that it does not append '
                                   db 'any newline at the end of the string automatically.',10
                                   db 'Use ''\n'' at the end if you need it.',10
                                   db 10,'Usage:',10,10
                                   db '    ',CL_GREEN,'%s',CL_RESET,' ''string to be printed'' | '
                                   db CL_GREEN,'%s',CL_RESET,' "string to be printed"',10,10
                                   db 'For better output control, avoid whenever possible "double '
                                   db 'quoted string", because it should also contain shell specific '
                                   db 'escapes or character codes for certain characters.',10,10
                                   db 'Supported escape sequences:',10,10
                                   db '  ',CL_YELLOW,'\"',CL_RESET,' | ',CL_YELLOW,'\42',CL_RESET
                                   db ' double quote char',10
                                   db '  ',CL_YELLOW,"\'",CL_RESET,' | ',CL_YELLOW,'\47',CL_RESET
                                   db ' single quote char',10
                                   db '  ',CL_YELLOW,'\',CL_ORANGE,'NNN',CL_RESET,' | '
                                   db CL_YELLOW,'\',CL_ORANGE,'NN',CL_RESET
                                   db ' | ',CL_YELLOW,'\',CL_ORANGE,'N',CL_RESET
                                   db ' octal, where N = octal digit',10
                                   db '  ',CL_YELLOW,'\?',CL_RESET,' question mark char',10
                                   db '  ',CL_YELLOW,'\U',CL_ORANGE,'XXXXXXXX',CL_RESET
                                   db ' UTF-32 char, where XXXXXXXX = hex number for UTF-32 code point',10
                                   db '  ',CL_YELLOW,'\\',CL_RESET,' backslash char',10
                                   db '  ',CL_YELLOW,'\a',CL_RESET,' alarm (usually a beep, shell/'
                                   db 'OS specific)',10
                                   db '  ',CL_YELLOW,'\b',CL_RESET,' backspace control code (0x8)',10
                                   db '  ',CL_YELLOW,'\e',CL_RESET,' | ',CL_YELLOW,'\33',CL_RESET
                                   db ' escape char (0x1B)',10
                                   db '  ',CL_YELLOW,'\f',CL_RESET,' form feed control code (0xC)',10
                                   db '  ',CL_YELLOW,'\n',CL_RESET,' new line control code (0xA)',10
                                   db '  ',CL_YELLOW,'\r',CL_RESET,' car return control code (0xD)',10
                                   db '  ',CL_YELLOW,'\t',CL_RESET,' tab control code (0x9)',10
                                   db '  ',CL_YELLOW,'\u',CL_ORANGE,'XXXX',CL_RESET
                                   db ' UTF-16 char, where XXXX = hex number for UTF-16 code point',10
                                   db '  ',CL_YELLOW,'\v',CL_RESET,' vertical tab control code (0xB)',10
                                   db '  ',CL_YELLOW,'\x',CL_ORANGE,'HH',CL_RESET
                                   db ' hex byte, where HH = hex number',10
                                   db 10,'Any malformed escape sequence or unsupported escape code '
                                   db '(e.g., ''\j'' or ''\92'') will be printed as is, without escaping.',10
                                   db 'This behavior allows, for example, either ''\?'' or ''?'' to print the '
                                   db 'same ''?'' char.',10
                                   db 0

_code
          ParseEscapedString:      endbr64   ; rdi = destination buffer; rsi = source string
                                   push      rbx
                                   lea       rbx, [escapetable-20h]
               .nextchar:          lodsb
                                   test      al, al
                                   jz        .endsuccess
                                   cmp       al, '\'
                                   je        .escape
                                   stosb
                                   jmp       .nextchar
               .endsuccess:        clc
                                   pop       rbx
                                   stosb
                                   ret
               .escape:            lodsb
                                   test      al, al
                                   js        .ignoreescape
                                   cmp       al, 20h
                                   jb        .ignoreescape
                                   xlatb
                                   test      al, -1
                                   jns       .store
                                   cmp       al, 254
                                   je        .octal
                                   cmp       al, 253
                                   je        .hex
                                   cmp       al, 252
                                   je        .utf16
                                   cmp       al, 251
                                   je        .utf32
               .ignoreescape:      mov       ax, [rsi-2]
                                   stosw
                                   jmp       .nextchar
               .store:             stosb
                                   jmp       .nextchar
               .octal:             mov       eax, [rsi-1]
                                   mov       ch, 1     ; Invalid octal flag before process
                                   cmp       al, '0'
                                   jb        .endoctal
                                   cmp       al, '7'
                                   ja        .endoctal
                                   xor       ecx, ecx  ; Valid octal + cl = number of octal chars
                                   sub       al, '0'
                                   movzx     edx, al
                                   inc       cl
                                   shr       eax, 8
                                   cmp       al, '0'
                                   jb        .endoctal
                                   cmp       al, '7'
                                   ja        .endoctal
                                   sub       al, '0'
                                   shl       edx, 3
                                   inc       cl
                                   or        dl, al
                                   shr       eax, 8
                                   cmp       al, '0'
                                   jb        .endoctal
                                   cmp       al, '7'
                                   ja        .endoctal
                                   sub       al, '0'
                                   shl       edx, 3
                                   or        dl, al
                                   inc       cl
               .endoctal:          test      ch, ch
                                   jnz       .ignoreescape
                                   lea       rsi, [rsi+rcx-1]
                                   mov       al, dl
                                   stosb
                                   jmp       .nextchar
               .hex:               mov       dx, [rsi] ; supporting 2 char hex \xNN
                                   mov       ch, 1     ; Set invalid flag before process
                                   cmp       dx, '00'
                                   jb        .endhex
                                   cmp       dx, 'ff'
                                   ja        .endhex
                                   sub       dx, '00'
                                   cmp       dl, 9
                                   jbe       @f
                                   sub       dl, 7
                                   cmp       dl, 0Fh
                                   jbe       @f
                                   sub       dl, 20h
                                   cmp       dl, 0Fh
                                   ja        .endhex
                                   cmp       dl, 0Ah
                                   jb        .endhex
                              @@   cmp       dh, 9
                                   jbe       @f
                                   sub       dh, 7
                                   cmp       dh, 0Fh
                                   jbe       @f
                                   sub       dh, 20h
                                   cmp       dh, 0Fh
                                   ja        .endhex
                                   cmp       dh, 0Ah
                                   jb        .endhex
                              @@   xor       ch, ch    ; Valid hex escape
               .endhex:            test      ch, ch
                                   jnz       .ignoreescape
                                   shl       dl, 4
                                   or        dl, dh
                                   mov       al, dl
                                   stosb
                                   add       rsi, 2
                                   jmp       .nextchar
               .utf16:             mov       edx, [rsi]
                                   mov       ch, 1     ; set invalid
                                   cmp       edx, '0000'
                                   jb        .endu16
                                   cmp       edx, 'ffff'
                                   ja        .endu16
                                   sub       edx, '0000'
                                   mov       cl, 4
                              @@@  cmp       dl, 9
                                   jbe       @f3
                                   sub       dl, 7
                                   cmp       dl, 0Ah
                                   jb        .endu16
                              @@   cmp       dl, 0Fh
                                   jbe       @f2
                                   sub       dl, 20h
                                   cmp       dl, 0Ah
                                   jb        .endu16
                              @@   cmp       dl, 0Fh
                                   ja        .endu16
                                   test      dl, dl
                                   js        .endu16
                              @@   ror       edx, 8
                                   dec       cl
                                   jnz       @@b
                                   bswap     edx
                                   shl       dh, 4
                                   or        dl, dh
                                   ror       edx, 16
                                   shl       dh, 4
                                   or        dl, dh
                                   ror       edx, 16
                                   mov       eax, edx
                                   ror       eax, 8
                                   movzx     edx, dl
                                   or        dh, ah
                                   xor       ch, ch
                                   call      .utf8enc
                                   jc        .ignoreescape
               .endu16:            test      ch, ch
                                   jnz       .ignoreescape
                                   stosd
                                   movzx     ecx, cl
                                   sub       rcx, 4
                                   add       rdi, rcx
                                   add       rsi, 4
                                   jmp       .nextchar
               .utf32:             mov       edx, [rsi]
                                   mov       eax, [rsi+4]
                                   mov       ch, 1
                                   cmp       edx, '0000'
                                   jb        .endu32
                                   cmp       eax, '0000'
                                   jb        .endu32
                                   cmp       edx, 'ffff'
                                   ja        .endu32
                                   cmp       eax, 'ffff'
                                   ja        .endu32
                                   bswap     eax
                                   bswap     edx
                                   sub       eax, '0000'
                                   sub       edx, '0000'
                                   mov       cl, 4
                              @@@  cmp       al, 9
                                   jbe       @f3
                                   sub       al, 7
                                   cmp       al, 0Ah
                                   jb        .endu32
                              @@   cmp       al, 0Fh
                                   jbe       @f2
                                   sub       al, 20h
                                   cmp       al, 0Ah
                                   jb        .endu32
                              @@   cmp       al, 0Fh
                                   ja        .endu32
                                   test      al, al
                                   js        .endu32
                              @@   ror       eax, 8
                                   cmp       dl, 9
                                   jbe       @f3
                                   sub       dl, 7
                                   cmp       dl, 0Ah
                                   jb        .endu32
                              @@   cmp       dl, 0Fh
                                   jbe       @f2
                                   sub       dl, 20h
                                   cmp       dl, 0Ah
                                   jb        .endu32
                              @@   cmp       dl, 0Fh
                                   ja        .endu32
                                   test      dl, dl
                                   js        .endu32
                              @@   ror       edx, 8
                                   dec       cl
                                   jnz       @@b
                                   push      rcx
                                   push      rbx
                                   shl       ah, 4
                                   shl       dh, 4
                                   or        al, ah
                                   or        dl, dh
                                   xor       ah, ah
                                   xor       dh, dh
                                   ror       eax, 16
                                   ror       edx, 16
                                   shl       ah, 4
                                   shl       dh, 4
                                   or        ah, al
                                   or        dh, dl
                                   xor       al, al
                                   xor       dl, dl
                                   mov       ebx, eax
                                   mov       ecx, edx
                                   ror       eax, 16
                                   ror       edx, 16
                                   or        ax, bx
                                   or        dx, cx
                                   movzx     eax, ax
                                   shl       edx, 16
                                   or        edx, eax
                                   pop       rbx
                                   pop       rcx
                                   call      .utf8enc
                                   jc        .endu32
                                   xor       ch, ch
               .endu32:            test      ch, ch
                                   jnz       .ignoreescape
                                   stosd
                                   movzx     ecx, cl
                                   sub       rcx, 4
                                   add       rdi, rcx
                                   add       rsi, 8
                                   jmp       .nextchar
               .utf8enc:           cmp       edx, 7Fh
                                   ja        @f
                                   mov       cl, 1          ; encoding length
                                   mov       eax, edx       ; eax = UTF-8 bytes
                                   clc
                                   ret
                              @@   cmp       edx, 7FFh
                                   ja        @f
                                   mov       cl, 2
                                   mov       eax, 00000C080h
                                   shl       dh, 2
                                   or        ah, dh
                                   mov       dh, dl
                                   and       dx, 0C03Fh
                                   shr       dh, 6
                                   or        ax, dx
                                   xchg      ah, al
                                   clc
                                   ret
                              @@   cmp       edx, 0FFFFh
                                   ja        @f
                                   mov       cl, 3
                                   mov       eax, 00E08080h
                                   push      rdx
                                   and       dx, 0F3Fh
                                   shl       dh, 2
                                   or        ax, dx
                                   pop       rdx
                                   shr       dl, 6
                                   shr       dh, 4
                                   or        ah, dl
                                   xor       dl, dl
                                   shl       edx, 8
                                   or        eax, edx
                                   rol       eax, 8
                                   bswap     eax
                                   clc
                                   ret
                              @@   cmp       edx, 10FFFFh   ; maximum UTF-32 code point
                                   ja        .utf8err
                                   mov       cl, 4
                                   mov       eax, 0F0808080h
                                   push      rdx       ; process xyz
                                   and       dx, 0F3Fh
                                   shl       dh, 2
                                   or        ax, dx
                                   mov       edx, [rsp]
                                   shr       dl, 6
                                   or        ah, dl
                                   pop       rdx
                                   shr       edx, 12   ; discard xyz, process uvw
                                   push      rdx
                                   and       dx, 013Fh
                                   shl       dh, 2
                                   ror       eax, 16
                                   or        ax, dx
                                   pop       rdx
                                   shr       dl, 6
                                   or        ah, dl
                                   rol       eax, 16
                                   bswap     eax
                                   clc
                                   ret
                    .utf8err:      stc
                                   ret


          Start:                   endbr64
                                   cmp       [rsp], dword 2
                                   jne       .err0
                                   mov       rbp, [rsp+16]  ; argv[1]
                                   mov       rdi, [rsp+16]  ; argv[1]
                                   xor       al, al
                                   mov       ecx, -1        ; 4 GB string limit
                                   repne     scasb
                                   not       ecx            ; String size with \0 char
                                   malloc(ecx);
                                   test      rax, rax
                                   jz        .err1
                                   mov       rsi, rbp
                                   mov       rdi, rax
                                   mov       rbp, rax
                                   call      ParseEscapedString
                                   sub       rdi, rbp
                                   fwrite(rbp, &edi-1, 1, **stdout);
                                   free(rbp);
                                   exit(0);

               .err1:              errno();
                                   mov       ebx, [rax]
                                   perror("Parsing failed");
                                   exit(ebx);
               .err0:              mov       rdi, [rsp+8]   ; exec name and path argv[0]
                                   mov       r11, rdi
                                   xor       al, al
                                   mov       ecx, -1
                                   repne     scasb
                                   not       ecx
                                   sub       rdi, 2
                                   mov       al, '/'
                                   std
                                   repne     scasb
                                   jne       @f
                                   add       rdi, 2
                                   jmp       @f2
                              @@   mov       rdi, r11
                              @@   cld
                                   fprintf(**stderr, &helper, rdi, rdi);
                                   exit(1);
