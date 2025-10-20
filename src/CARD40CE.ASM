;****************************************************************
;
;      Harddisk Protect Card  Assemble Language Source Code
;
;                      Enhanced Version 3.0 (E)
;
;                  ( With Anti-LowForm In BIOS )
;
;****************************************************************
;
;                                        Written By Mr. ZhangYan
;
;                                The Last Modify: Jan  3,1995
;
;                                The Last Modify: Feb 21,1995
;
;                              *  Modify display characters way
;                              *  and Rights Message
;
;                                The Last Modify: Feb 23,1995
;
;                              *  All modify for new type
;       # Problem :
;                 No write protect in Windows 32 bit disk access
;
;                               The Last Modify: March 14,1995
;
;                              * Solve PC Hang Problem When
;                                Format A:/4 (no 'U' Parameter)
;
;                               The Last Modify: March 21,1995
;
;                              * Rewrite Delay Subroutine For
;                                     286 From Korea.
;
;                             The Last Modify: August 20,1995
;
;                              * Add some Encrypt Feature
;
;                          The Last Modify: September 14,1995
;
;                              * Add Plug and Play Feature
;
;                           The Last Modify: Septemer 27,1995
;
;                              * Add Function Select Feature
;                              * Add Dos File Support Feature
;
;                           The Last Modify: October 3,1995
;
;                      * Fix a Bug In Int21h 4Fh,12h Function
;
;                           The Last Modify: December 20, 1995
;
;                      * Run Program From V Directory
;                      * Ah=4b
;                      * Ax=6c00h int 21h
;
;                           The Last Modify: May 6, 1996
;
;                      * Add CMOS Data Check Mask
;                      * Upgrade To Version 3.0
;                      * Add Encrypt Disk Function
;
;                           The Last Modify: May 16, 1996
;
;                      * Add Anti-LowFrom In BIOS Feature
;
;                           The Last Modify: June 5, 1996
;
;                      * Add Int 1 & Int 3
;
;                           The Last Modify: June 9, 1996
;
;                      * Setup Encrypt Disk Not Default
;                      * Setup Flash Prompt Optional
;
;                           The Last Modify: June 11, 1996
;
;                           The Last Modify: Oct 23, 1997
;
;                      * Setup Windows 95 Optional
;                      * Anti-DieHard
;
;                           The Last Modify: Mar 8, 1998
;                      * Dynamic setup parameters
;                      * Change CMOS restore method
;                        Not restore if read backup error
;                      * Diable Int 21h support, if one partion.
;
;****************************************************************
;        Chinese Windows 3.1       MS-Windows 3.1
;  int8       11ea:0000               068f:0000
;  int10      11f5:000f               06b4:0000
;  int15      11e3:0001               0651:0000
;  int1c      11ea:0098               068f:0098  *
;  int2f      1174:02a7               05e2:02a7  *
;****************************************************************
;                     PUC 5.1             WPS 2.0
;Interrupt  8        2537:7FCE           3c3e:09f1
;Interrupt  9        0D90:0045           3c3e:0c53
;****************************************************************
;                     WPSNT               WPS NT
;Interrupt  9        0DC3:0045           1E95:100E
;****************************************************************
;                     PUC 6.0F            WPS 3.0F
;Interrupt  8        1EEB:B35C           4013:0b01
;Interrupt  9        1BD7:0045           4013:0eb9
;****************************************************************
;                    ACIOS 3.1            WPS 2.2
;Interrupt  8        CA55:22D7           3303:0A7E
;Interrupt  9        20f2:01D6           20f2:01C7
;****************************************************************
;                    ACIOS                WPS 2.2
;Interrupt  8        1DE4:010B           2CB5:0A7E
;Interrupt  9        0705:2A25           2CB5:0DFE
;****************************************************************
;                   UCDOS 3.0            WPS 2.2
;Interrupt  8        1A15:010B           1D67:0A7E
;Interrupt  9        0619:30FB           1D67:16B4
;****************************************************************
;                   UCDOS 3.1            WPS 2.2
;Interrupt  8        DA07:170E           11C6:0A7E
;Interrupt  9        073A:01C7           0E3F:065A
;****************************************************************
;                   UCDOS 5.0            WPS 2.2
;Interrupt  8        070C:010B           0F0C:0A7E
;Interrupt  9        DB88:2088           0B69:067B
;****************************************************************
;                    TWAY 2.1             WPS 2.2
;Interrupt  8        1A15:010B           3902:0A7E
;Interrupt  9        0619:2860           1D67:0DFE
;****************************************************************
;                    CXDOS 6.0            WPS 2.2F
;Interrupt  8        07bc:3f84           0F93:0A7E
;Interrupt  9        D312:1923           0F93:0DFE
;****************************************************************
;
;  Addr. 96h*4: --- tflag
;
;  Bit  07     06     05     04     03     02     01     00
;      ----    ---------     ---------     --     --     --
;    int9bit     stype        date_4      flag2  sflag  sflag2
;
;****************************************************************
;
;  Addr.  94h*4   94h*4+1   94h*4+2   94h*4+3   95h*4   95h*4+2
;         endcl    endch     enddl     enddh    scount   count
;
;****************************************************************
int9bit   equ   10000000b
stypebit  equ   01100000b
drivebit  equ   00011000b
flag2bit  equ   00000100b
sflag1bit equ   00000010b                  ;Reenter Int 8h
sflag2bit equ   00000001b                  ;Screen Closed
;************************  Start  **************************
code      segment
          assume cs:code,ds:code
          org  0h
flag      db   55h,0aah,10h
start:    jmp  begin
disp      db   'Enter password:'
mes1      db   'Press <ESC> to remove Hard Disk Protector . . .',0
cmosm     db   "CMOS was changed, restore CMOS and restart computer !",0
nohdm     db   "No Hard disk in this Computer !                 ",0
verm      db   "ีอออออออออออออออออออออออออออออออออออออออออออออออธ",0dh,0ah
          db   "ณ  Hard Disk Protector Enhanced Version 3.1     ณ",0dh,0ah
          db   "ณ  All Rights Reserved ! 1997-1999              ณ",0dh,0ah
          db   "ณ  (C) Programed by Mr. Zhangyan, 1994-1999.    ณ",0dh,0ah
          db   "ณ  HTTP://fly.to/zhyan     EMAIL:zhyan@usa.net  ณ",0dh,0ah
          db   "ิอออออออออออออออออออออออออออออออออออออออออออออออพ",0
;         db   "ณ  (C) CARDO Network & Communication Co., Ltd.  ณ",0dh,0ah
back      db   "                                                 Ü",0dh,0ah
          db   "                                                 Û",0dh,0ah
          db   "                                                 Û",0dh,0ah
          db   "                                                 Û",0dh,0ah
          db   "                                                 Û",0dh,0ah
          db   " ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿",0dh,0ah,0

;         db   "Not SETUP !",0dh,0ah
nosetupm  db   "HardDisk Protector setup automatically .",0dh,0ah,0
opencard  db   "Hard Disk Protector is removed !",0dh,0ah,0
errorpass db   "Password error !",0dh,0ah,0
base      db   0dfh,02h,25h,02h,0ah,1bh,0ffh,2ah,0f6h,0fh,8
setsap    db   12h,34h,0,0,0,0,5,0dbh,0c1h,92h,0d3h,0f3h,3ch,0dh
pr:       db   5eh,0ech,3dh,0dch,70h,0e0h,1
;         pushf
;         call dword ptr cs:int13off
;         ret
          db   0
ztmp0     db  'C:\HDPRT\'
zsdrive   db  'D:\HDPRT\'
zddrive   db  'D:\'

;******************************************************
;
;  Interupt 8h Entry Point
;
;******************************************************
int82:  pushf
        sti
        cmp   cs:sflag1,0            ; Reenter ?
        jz    bbb                    ; No
        jmp   jmp8                   ; Yes
bbb:    mov   cs:sflag1,1            ; Enter Flag
        push  ax
        push  bx
        push  cx
        push  dx
        push  si
        push  di
        push  bp
        push  ds
        push  es
        xor   ax,ax
        mov   es,ax
        cmp   es:[9*4],100eh          ;NT
        jnz   tpuc5
        jmp   iwps
tpuc5:  cmp   es:[8*4],09f1h          ;puc 5.1
        jnz   tpuc6
        jmp   cc
tpuc6:  cmp   es:[8*4],0b01h          ;puc 6.0f
        jnz   tpuc7
        jmp   cc
tpuc7:  cmp   es:[8*4],0a7eh          ;acios 3.1
        jz    cc
        mov   cs:cgflag,0               ; Change Vec Flag <- 0
        jmp   int802
cc:     mov   ax,es:[9*4]
        cmp   ax,65ah
        jz    iwps
        cmp   ax,67bh
        jz    iwps
        cmp   ax,0c53h
        jz    iwps
        cmp   ax,0eb9h
        jz    iwps
        cmp   ax,1c7h
        jz    iwps
        cmp   ax,16b4h
        jz    iwps
        cmp   ax,0dfeh
        jz    iwps
        cmp   ax,100eh
        jz    iwps
        mov   cs:cgflag,0            ; Not In WPS
        jmp   int802
iwps:   cmp   cs:cgflag,0            ; In WPS
        jz    n0                     ; Not Changed
        jmp   int802                 ; Changed
n0:     cli
        mov   ax,es:[09h*4]
        mov   cs:s09off,ax
        mov   ax,es:[09h*4+2]
        mov   cs:s09seg,ax
        call  save
        mov   cs:cgflag,1
int802:
        test  cs:funcf,1             ; No This Function
        jnz   test96
        jmp   exit8
test96:
        cmp   cs:sflag2,1            ;Screen Closed ?
        jnz   or96
        jmp   exit8

or96:
        mov   cs:sflag1,1
        inc   cs:count

        mov   ax,cs:scount
        cmp   ax,cs:count
        jna   twin
        jmp   exit8
twin:   mov   ax,1600h
        int   2fh
        cmp   al,01h
        jz    inwin
        cmp   al,0ffh
        jz    inwin
        cmp   al,0
        jz    tagain
        cmp   al,80h
        jnz   inwin
tagain: mov   ax,4680h
        int   2fh
        cmp   al,80h
        jnz   inwin
        jmp   go
inwin:
        mov   cs:count,0
        jmp   exit8

go:     cmp   cs:sctype,0
        jnz   scm1
        call  offvga
        jmp   exit8
scm1:   cmp   cs:sctype,1
        jnz   scm2
        call  offega
        jmp   exit8
scm2:   cmp   cs:sctype,2
        jnz   scm3
        call  offcga
        jmp   exit8
scm3:   cmp   cs:sctype,3
        jnz   exit8
        call  offmda
exit8:  pop  es
        pop  ds
        pop  bp
        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        mov  cs:sflag1,0
jmp8:   popf
        jmp  dword ptr cs:int8off

offvga    proc
          push  ax
          push  dx
          cli
          mov   cs:count,0
          mov   dx,3c4h
          mov   al,1
          out   dx,al
          inc   dx
          in    al,dx
          or    al,20h
          dec   dx
          mov   ah,1
          xchg  al,ah
          out   dx,ax
          mov   cs:sflag2,1
          sti
          pop   dx
          pop   ax
          ret
offvga    endp

offega    proc
          push ax
          push dx
          cli
          mov  cs:count,0
          mov  dx,3dah
          in   al,dx
          mov  dx,3c0h
          mov  al,0
          out  dx,al
;         or   byte ptr ds:tflag,sflag2bit          ;1
          mov  cs:sflag2,1
          sti
          pop  dx
          pop  ax
          ret
offega    endp

offcga   proc
         push ax
         push dx
         cli
         mov  cs:count,0
         mov  dx,3d8h
         xor  ax,ax
         mov  ds,ax
         mov  al,byte ptr es:[465h]
         and  al,0f7h
         out  dx,al
         mov  byte ptr es:[465h],al
;        or   byte ptr ds:tflag,sflag2bit           ;1
         mov  cs:sflag2,1
         sti
         pop  dx
         pop  ax
         ret
offcga   endp
offmda   proc
         push ax
         push dx
         mov  cs:count,0
         mov  dx,3b8h
         xor  ax,ax
         mov  ds,ax
         mov  al,byte ptr es:[465h]
         and  al,0f7h
         out  dx,al
         mov  byte ptr es:[465h],al
         mov  cs:sflag2,1
         pop  ds
         pop  dx
         pop  ax
         ret
offmda   endp

;******************************************************
;
;  Interupt 9h Entry Point
;
;******************************************************

int9:    sti
         pushf
         push ax
         push es
         xor  ax,ax
         mov  es,ax
         test word ptr es:[0417h],8
         jz   ss5
         test word ptr es:[0417h],4
         jz   ss5
         in   al,60h
         cmp  al,53h
         jz   openlock
         cmp  al,1
         jnz  ss5
openlock:mov  dx,1f7h
         mov  al,0
         out  dx,al
         mov  cs:reset,1234h
         mov  es:[472h],1234h
         pop  es
         pop  ax
         popf
         db   0eah,0,0,0ffh,0ffh
ss5:     pop  es
         pop  ax
         popf
         pushf
         call dword ptr cs:int9off
         mov  cs:count,0
         cmp  cs:sflag2,1
         jnz  exit9
         push ax
         push dx
         mov  ah,1
         int  16h
         jz   offit
         mov  ah,0
         int  16h
offit:
         cmp  cs:sctype,0
         jnz  scm5
         call onvga
         jmp  wflag
scm5:
         cmp  cs:sctype,1
         jnz  scm6
         call onega
         jmp  wflag
scm6:
         cmp  cs:sctype,2
         jnz  scm7
         call oncga
         jmp  wflag
scm7:
         cmp  cs:sctype,3
         jnz  wflag
         call onmda
wflag:
         mov  cs:count,0
         mov  cs:sflag2,0
         pop  dx
         pop  ax
exit9:   iret
int09:   pushf
         sti
         push ax
         push bx
         push cx
         push dx
         push si
         push di
         push bp
         push ds
         push es
         cmp  cs:in9,0
         jz   setflag
         jmp  s5
setflag: mov  cs:in9,1
         xor  ax,ax
         mov  es,ax
         test word ptr es:[0417h],8
         jz   s50
         test word ptr es:[0417h],4
         jz   s50
         in   al,60h
         cmp  al,53h
         jnz  s50
         mov  dx,1f7h
         mov  al,0
         out  dx,al
         mov  cs:reset,1234h
         mov  es:[472h],1234h
         db   0eah,0,0,0ffh,0ffh
s50:
        mov  cs:count,0
        cmp  cs:sflag2,1
        jnz  s501
        push ax
        push dx
        mov  ah,1
        int  16h
        jz   offit0
        mov  ah,0
        int  16h
offit0:
        cmp  cs:sctype,0
        jnz  scm50
        call onvga
        jmp  wflag0
scm50:
        cmp  cs:sctype,1
        jnz  scm60
        call onega
        jmp  wflag0
scm60:
        cmp  cs:sctype,2
        jnz  scm70
        call oncga
        jmp  wflag0
scm70:
        cmp  cs:sctype,3
        jnz  wflag0
        call onmda
wflag0:
        mov  cs:count,0
        mov  cs:sflag2,0
        pop  dx
        pop  ax
s501:   mov  cs:in9,0
s5:     call restore
        pop  es
        pop  ds
        pop  bp
        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        popf
        pushf
        call dword ptr cs:s09off
        call save
        iret
save    proc
        pushf
        push ds
        push es
        push cx
        push si
        push di
        cld
        mov  cx,5
        mov  si,cs:s09seg
        mov  ds,si
        mov  si,cs:s09off
        push cs
        pop  es
        mov  di,offset pro
        rep  movsb
        mov  byte ptr [si-5],0eah
        mov  word ptr [si-4],offset int09
        mov  word ptr [si-2],cs
        pop  di
        pop  si
        pop  cx
        pop  es
        pop  ds
        popf
        ret
save    endp
restore proc
        cld
        mov  cx,5
        mov  di,cs:s09seg
        mov  es,di
        mov  di,cs:s09off
        push cs
        pop  ds
        mov  si,offset pro
        rep  movsb
        ret
restore endp
onvga    proc
         cli
         mov  dx,3c4h
         mov  al,1
         out  dx,al
         inc  dx
         in   al,dx
         and  al,0dfh
         dec  dx
         mov  ah,1
         xchg al,ah
         out  dx,ax
         sti
         ret
onvga    endp
onega    proc
         cli
         mov  dx,3dah
         in   al,dx
         mov  dx,3c0h
         mov  al,20h
         out  dx,al
         sti
         ret
onega    endp

oncga   proc
        push ds
        cli
        mov  dx,3d8h
        xor  ax,ax
        mov  ds,ax
        mov  al,byte ptr ds:[465h]
        or   al,8
        out  dx,al
        mov  byte ptr ds:[465h],al
        sti
        pop  ds
        ret
oncga   endp
onmda   proc
        push ds
        cli
        mov  dx,3b8h
        xor  ax,ax
        mov  ds,ax
        mov  al,byte ptr ds:[465h]
        or   al,8
        out  dx,al
        mov  byte ptr ds:[465h],al
        sti
        pop  ds
        ret
onmda   endp

;******************************************************
;
;  Interupt 13h Entry Point
;
;******************************************************

int13:    pushf
          sti
          cmp  ah,18h
          jnz  pushds
          cmp  cx,4f0ah
          jnz  pushds
          cmp  bx,3412h
          jnz  pushds
          mov  bx,4321h
          popf
          iret
pushds:   push ds
          push cs
          pop  ds
s1:       cmp  dl,80h
          jz   s11
          test cs:funcf,2
          jz   exi
          pop  ds
          popf
          jmp  int13r
s11:      cmp  ah,2
          jnz  s2
          cmp  dh,0
          jz   cmpcx
exi:      jmp  exit
cmpcx:    cmp  cx,3
          ja   s2
          push ax
          push cx
          mov  ah,0
          add  cx,ax
          cmp  cx,3
          pop  cx
          pop  ax
          jnb  add00
          jmp  exit
add00:
          push cx
          push di
;         pushf
;         call cs:dword ptr int13off                    ;***
          call  call13
          push ax
          pushf

          xor  al,al
          mov  di,bx
          cmp  cx,1
          jnz  add01
          add  di,400h
          jmp  add02
add01:    cmp  cx,2
          jnz  add02
          add  di,200h
add02:    cld
          mov  cx,200h
          repz stosb

          popf
          pop  ax
          pop  di
          pop  cx
          pop  ds
          add  sp,2
          retf 2

s2:       cmp  ah,5
          jnz  c1
          pop  ds
          popf
          stc
          mov  ah,3
          retf 2
c1:       cmp  ah,3
          jnz  c3
          jmp  check
c3:       cmp  ah,6
          jnz  c4
          jmp  check
c4:       cmp  ah,7
          jnz  exit
check:    push ax
          push cx
          xchg ch,cl
          and  ch,0c0h
          shr  ch,1
          shr  ch,1
          shr  ch,1
          shr  ch,1
          shr  ch,1
          shr  ch,1
          mov  ax,word ptr cs:endcl
          xchg ah,al
          and  ah,0c0h
          shr  ah,1
          shr  ah,1
          shr  ah,1
          shr  ah,1
          shr  ah,1
          shr  ah,1
          cmp  cx,ax
          jb   out2
          ja   ext20
c5:       cmp  dh,byte ptr cs:enddh
          jb   out2
          ja   ext20
out2:     pop  cx
          pop  ax
          pop  ds
          test cs:funcf,8
          jz   nowin95
          popf
          clc
          mov  ah,0
          retf 2
nowin95:  popf
          stc
          mov  ah,3
          retf 2
ext20:    pop  cx
          pop  ax
exit:     pop  ds
          popf
;         jmp  dword ptr cs:int13off         ;***
;         pushf
;         call dword ptr cs:int13off
          call  call13
          retf  2
int13r:
          pushf
          cmp   dl,1
          jna   cmpah2
          jmp   exit1
cmpah2:   cmp   ah,2
          jz    mmo
          jmp   cmpnext
mmo:      mov   cs:vccx,cx
!         add   cs:vccx,100h
          mov   cs:vbx,bx
#         and   cs:vccx,0ff00h
          push  dx
!         mov   dl,dh
#
#         xor   dx,6543h
!         add   cs:vccx,dx
          pop   dx
          popf
;         pushf
;         call  dword ptr cs:int13off
          call  call13
          jnc   cango
          retf  2
cango:    pushf
          cmp   al,0
          jnz   th
          popf
          retf  2
th:       push  ax
          push  bx
          push  cx
          xor   cx,cx
addcx:    add   cx,256
          dec   al
          cmp   al,0
          ja    addcx
xorby:
          push  bx
          push  dx
          xor   dx,dx
          mov   ax,bx
          sub   ax,cs:vbx
          mov   bx,200h
          div   bx
          mov   ax,dx
          pop   dx
          pop   bx
          add   ax,cs:vccx
#
!         xor   es:word ptr [bx],ax
#
          inc   bx
          inc   bx
          loop  xorby

          pop   cx
          pop   bx
          pop   ax
          popf
          retf  2

cmpnext:  cmp   ah,3
          jz    write13
          jmp   exit1
write13:  cmp   al,0
          jnz   th2
          jmp   exit1
th2:      push  ax
          push  bx
          push  cx
#         mov   cs:vccx,cx
!         add   cs:vccx,100h
!         mov   cs:vbx,bx
#         and   cs:vccx,0ff00h
!         push  dx
          mov   dl,dh
          xor   dx,6543h
          add   cs:vccx,dx
          pop   dx
          xor   cx,cx
addcx1:   add   cx,256
          dec   al
          cmp   al,0
          ja    addcx1
          mov   cs:vvvc,cx
wri:
          push  bx
          push  dx
          xor   dx,dx
          mov   ax,bx
          sub   ax,cs:vbx
          mov   bx,200h
          div   bx
          mov   ax,dx
          pop   dx
          pop   bx
          add   ax,cs:vccx
!
#         xor   es:word ptr [bx],ax
#         inc   bx
          inc   bx
          loop  wri
          pop   cx
          pop   bx
          pop   ax
          popf
;         pushf
;         call  dword ptr cs:int13off
          call  call13
          pushf
          push  ax
          push  bx
          push  cx
          mov   cx,cs:vvvc
xorby2:
          push  bx
          push  dx
          xor   dx,dx
          mov   ax,bx
          sub   ax,cs:vbx
          mov   bx,200h
          div   bx
          mov   ax,dx
          pop   dx
          pop   bx
          add   ax,cs:vccx
#
!         xor   es:word ptr [bx],ax
!
          inc   bx
          inc   bx
          loop  xorby2
          pop   cx
          pop   bx
          pop   ax
          popf
          retf  2
exit1:    popf
          call  call13
          retf  2
;         jmp cs:dword ptr int13off

;******************************************************
;
;  Interupt 8h Entry Point (Temp)
;
;******************************************************

int8h:
          pushf
          push   ax
          push   bx
          push   cx
          push   dx
          push   si
          push   di
          push   bp
          push   ds
          push   es
          xor    ax,ax
          mov    es,ax
          cmp    cs:in8,0
          jz     canin
          jmp    eeee
canin:    mov    cs:in8,1                            ;In int8h ?
          mov    ax,0f000h
          cmp    es:word ptr [4eh],ax
          jnz    cmp21
          cli
          mov    es:word ptr [4ch],offset int13      ;int 13H
          mov    es:word ptr [4eh],cs
          sti
cmp21:    mov    bx,word ptr es:[21h*4+2]
          cmp    bx,2000h
          jae    eeee0
          cmp    bx,0
          je     eeee0
          cmp    bx,-1
          je     eeee0
          mov    cx,2000h
dela:     loop   dela
          cmp    cs:onedisk,1                      ;98/03/09
          jz     insac                             ;98/03/09
          mov    ax,word ptr es:[21h*4]
          mov    cs:int21off,ax                    ;int21off,ax
          mov    ax,word ptr es:[21h*4+2]
          mov    cs:int21seg,ax                    ;int21seg,ax
          mov    ax,offset int21
          cli
          mov    word ptr es:[21h*4],ax
          mov    word ptr es:[21h*4+2],cs
          sti
;         test   cs:funcf,1
;         jz     eeee0
insac:    cli
          mov    word ptr es:[8*4],offset int82
          mov    word ptr es:[8*4+2],cs
          sti
eeee0:    mov    cs:in8,0
eeee:     pop    es
          pop    ds
          pop    bp
          pop    di
          pop    si
          pop    dx
          pop    cx
          pop    bx
          pop    ax
          popf
          jmp    dword ptr cs:int8off
;******************************************************
;
;  Interupt 21h Entry Point
;
;******************************************************

int21:     pushf
           sti
           cmp  ah,40h
           jz   exit211
           cmp  ax,2534h
           jnz  real21
           cmp  dx,78ah
           jz   c0
           cmp  dx,0c12h
           jnz  real21
c0:        push es
           push bx
           push bp
           mov  bp,sp
           mov  ax,[bp+10]
           mov  es,ax
           mov  bx,[bp+8]
           cmp  es:[bx],0e240h
           jnz  exit210
           cmp  es:[bx+2],8bfbh
           jnz  exit210
           mov  [bp+8],offset into
           mov  [bp+10],cs
           pop  bp
           pop  bx
           pop  es
           popf
           iret
exit210:   pop  bp
           pop  bx
           pop  es
exit211:   popf
           jmp  dword ptr cs:int21off
real21:
           push ax
           push bx
           push cx
           push dx
           push si
           push di
           push bp
           push ds
           push es
           mov  cs:vax,ax
           mov  cs:vcx,cx
           mov  cs:vdx,dx
           mov  cs:vdi,di
           mov  cs:ves,es

cmp56:     cmp  ah,56h
           jnz  cmp41
           jmp  sea
cmp41:     cmp  ah,41h
           jnz  cmp4b
           jmp  sea
cmp4b:
           cmp  ah,4bh
           jnz  cmp6c
           jmp  sea
cmp6c:     cmp  ax,6c00h
           jnz  cmp3c
           jmp  sea

cmp3c:     cmp  ah,3ch
           jnz  cmp3d
           jmp  sea
cmp3d:     cmp  ah,3dh
           jnz  cmp5b
           jmp  sea

cmp5b:     cmp  ah,5bh
           jnz  cmp5a
           jmp  sea

cmp5a:     cmp  ah,5ah
           jnz  cmp43
           jmp  sea

cmp43:     cmp  ah,43h
           jnz  cmp4e
           jmp  sea
cmp4e:     cmp  ah,4eh
           jnz  cmp4f
           jmp  sea
cmp4f:     cmp  ah,4fh
           jnz  cmp11
           jmp  sea0
cmp11:     cmp  ah,11h
           jnz  cmp0f
           jmp  fcb1
cmp0f:     cmp  ah,0fh
           jnz  cmp10
           jmp  fcb1
cmp10:     cmp  ah,10h
           jnz  cmp13
           jmp  fcb1
cmp13:     cmp  ah,13h
           jnz  cmp16
           jmp  fcb1
cmp16:     cmp  ah,16h
           jnz  cmp17
           jmp  fcb1
cmp17:     cmp  ah,17h
           jnz  cmp12
           jmp  fcb1

cmp12:     cmp  ah,12h
           jnz  exitd
           jmp  fcb0

exitd:     jmp  exit0

;*********************  Sea0  ****************************

sea0:      cmp  cs:f4f,0
           jnz  lopu
           jmp  exit0
lopu:      pushf
           call dword ptr cs:int21off
           jc   gotoc
           jmp  exit4
gotoc:
;          cmp  cs:fname[0],'C'
;          jnz  goon0
;          jmp  exit4
goon0:     mov  cs:fname[0],'C'
           push si
           mov  si,offset fname+8
           call conv1
           pop  si
           mov  cx,cs:vcx2
           mov  dx,offset fname
           push cs
           pop  ds

           mov  ah,4eh
           pushf
           call dword ptr cs:int21off
           jc   exitc0
           push es
           push bx
           pushf
           mov  ah,2fh
           pushf
           call dword ptr cs:int21off
           cmp  byte ptr es:[bx+1eh],'.'
           jz   nov
nov0:      popf
           pop  bx
           pop  es
           mov  cs:f4f,0
           jmp  exit4
nov:       popf
           mov  ah,4fh
           pushf
           call dword ptr cs:int21off
           pushf
           cmp  byte ptr es:[bx+1eh],'.'
           jz   nov
           popf
           pop  bx
           pop  es
exitc0:    mov  cs:f4f,0
           jmp  exit4
exitc:     jmp  exit0

sea:       push cs
           pop  es
           cmp  ax,6c00h
           jz   cross
           mov  si,dx                   ;DS:DX = ASCIIZ
cross:     mov  di,offset fname
           cmp  ah,4eh
           jz   movah60
           mov  di,offset fname2
movah60:
           mov  ah,60h
           pushf
           call dword ptr cs:int21off   ;ES:DI = ASCIIZ
           jnc  p98
           jmp  exit0
p98:       cmp  byte ptr es:[di],'C'
           jz   p99
           jmp  exit0
p99:       push si
           mov  si,di
           call conv
           pop  si
           cmp  byte ptr cs:[di+9],3fh
           jz   jmpe0
           cmp  byte ptr cs:[di+9],0
           jz   jmpe0
           jmp  cmpcsf
jmpe0:     jmp  exit0
cmpcsf:    cmp  byte ptr cs:[di+0],'C'
           jz   found
           jmp  exit0
found:
           mov  byte ptr cs:[di+0],'D'
           push cs
           pop  ds
           mov  ax,cs:vax
           mov  cx,cs:vcx
           cmp  ax,6c00h
           jnz  cross2
           mov  si,di
           jmp  cross3
cross2:    mov  dx,di
cross3:    cmp  ah,56h
           jnz  cross4

           push ds
           mov  si,cs:ves
           mov  ds,si
           mov  si,cs:vdi
           push cs
           pop  es
           mov  di,offset fname3
           mov  ah,60h
           pushf
           call dword ptr cs:int21off   ;ES:DI = ASCIIZ
           jnc  p990
           pop  ds
           jmp  exit0
p990:      push si
           mov  si,di
           call conv
           pop  si
           mov  byte ptr cs:[di+0],'D'
           mov  ax,cs:vax
           pop  ds

cross4:    pushf
           call dword ptr cs:int21off
           jnc  exit4

exit0:     pop  es
           pop  ds
           pop  bp
           pop  di
           pop  si
           pop  dx
           pop  cx
           pop  bx
           pop  ax
           popf
           jmp  dword ptr cs:int21off
exit4:
           mov  cs:vax2,ax
           mov  cs:vcx3,cx
           pop  es
           pop  ds
           pop  bp
           pop  di
           pop  si
           pop  dx
           pop  cx
           pop  bx
           pop  ax
           pop  ax
           mov  ax,cs:vax
           pushf
           cmp  ah,5ah
           jnz  cmpah3d
           push ds
           push es
           push cx
           push si
           push di
           mov  si,dx
loadsb:    lodsb
           cmp  al,0
           jnz  loadsb
           cmp  byte ptr [si-2],'\'
           jnz  ngg0
           dec  si
ngg0:      mov  byte ptr [si-1],'\'
ngg:       push si
           push cs
           pop  es
           mov  di,offset fname2
           mov  cx,-1
           mov  al,0
           cld
           repnz scasb
           dec  di
           mov  si,di
           pop  di

           push ds
           pop  es
           push cs
           pop  ds
           xor  cx,cx
serl:      cmp  byte ptr cs:[si],'\'
           jz   nhh
           dec  si
           inc  cx
           jmp  serl
nhh:       inc  si
           repz movsb
           pop  di
           pop  si
           pop  cx
           pop  es
           pop  ds
           jmp  goret
cmpah3d:   cmp  ah,3dh
           jnz  cmpah43
           mov  ax,cs:vax2
           jmp  goret
cmpah43:   cmp  ax,4300h
           jnz  cmpah4e
           mov  cx,cs:vcx3
           jmp  goret
cmpah4e:   cmp  ah,4eh
           jnz  pregoret
           mov  cs:f4f,1
           mov  cs:vcx2,cx
           jmp  goret
pregoret:  cmp  ah,11h
           jnz  goret
           mov  cs:f12,1
goret:     popf
           mov  ax,cs:vax2
           retf 2

;**************************  Fcb Function  *******************************

fcb0:      cmp  cs:f12,0
           jnz  lfcb1
           jmp  exit0
lfcb1:
           pushf
           call dword ptr cs:int21off
           cmp  al,0ffh
           jz   gotoc2
           jmp  exit4
gotoc2:
           mov  bx,dx
           cmp  byte ptr [bx],0ffh
           jnz  gon
           add  bx,7
;          cmp  byte ptr [bx],3
;          jnz  gon
;          jmp  exit4
gon:       mov  byte ptr [bx],3
goext:     mov  ah,11h
           pushf
           call dword ptr cs:int21off
           cmp  al,0ffh
           jnz  pushes0
           jmp  exit0
pushes0:   push es
           push bx
           pushf
           mov  ah,2fh
           pushf
           call dword ptr cs:int21off
           cmp  byte ptr es:[bx],0ffh
           jnz  noextfcb
           add  bx,7
noextfcb:  cmp  byte ptr es:[bx+1],'.'
           jz   nov2
nov01:     popf
           pop  bx
           pop  es
           mov  cs:f12,0
           jmp  exit4
nov2:      popf
           mov  ah,12h
           pushf
           call dword ptr cs:int21off
           pushf
           cmp  al,0ffh
           jz   eed
           cmp  byte ptr es:[bx+1],'.'
           jz   nov2
eed:       popf
           pop  bx
           pop  es
           mov  cs:f12,0
           jmp  exit4

fcb1:      mov  bx,dx
           cmp  byte ptr [bx],0ffh
           jnz  noext
           add  bx,7
noext:     cmp  byte ptr [bx],0
           jnz  cmpinc
           mov  ah,19h
           pushf
           call dword ptr cs:int21off
           cmp  al,2
           jz   indc
           jmp  exit0
cmpinc:    cmp  byte ptr [bx],3
           jz   indc
           jmp  exit0
indc:      push ds
           pop  es
           push cs
           pop  ds

           mov  ah,47h                       ; Get Current Directory
           mov  dl,3                         ; C:
           mov  si,offset spath
           pushf
           call dword ptr cs:int21off
           cmp  cs:spath,0
           jnz  movah47
           jmp  exit0
movah47:   mov  ah,47h                       ; D:
           mov  dl,4
           mov  si,offset dpath
           pushf
           call dword ptr cs:int21off
;          push si
;          mov  si,offset sdrive
;          call conv
;          pop  si
           mov  ah,3bh                       ; Set Current Directory
           mov  dx,offset sdrive
           pushf
           call dword ptr cs:int21off
           jnc  step0
           jmp  exit0
step0:     mov  ah,0eh                       ;Set Current Driver
           mov  dl,3
           pushf
           call dword ptr cs:int21off
step1:
           mov  byte ptr es:[bx],4
           push ds
           push es
           pop  ds
           mov  ax,cs:vax
           mov  dx,cs:vdx
           pushf
           call dword ptr cs:int21off
           pop  ds
           jc   step02
           jmp  step20
step02:    mov  byte ptr es:[bx],3
           mov  ah,3bh                       ; Set Current Directory
           mov  dx,offset ddrive             ; D:
           pushf
           call dword ptr cs:int21off
           mov  ah,0eh                       ; Set Current Driver
           mov  dl,2                         ; C:
           pushf
           call dword ptr cs:int21off
           jmp  exit0
step20:    cmp  al,0ffh
           jnz  step2
           jmp  step02
step2:
           mov  cs:vax,ax
           mov  byte ptr es:[bx],3
           mov  ah,3bh                       ; Set Current Directory
           mov  dx,offset ddrive             ; D:
           pushf
           call dword ptr cs:int21off
           jnc  step6
           mov  ah,0eh                       ; Set Current Driver
           mov  dl,2                         ; C:
           pushf
           call dword ptr cs:int21off
           jmp  exit0

step6:     mov  ah,0eh                       ;Set Current Driver
           mov  dl,2                         ;C:
           pushf
           call dword ptr cs:int21off
           mov  ax,cs:vax
           jmp  exit4

;***************************************************
;                  Convert String
;  Input si
;***************************************************

conv       proc
           pushf
           push ds
           push es
           push cx
           push di
           push ax
           push si

           push cs
           pop  ds
           push cs
           pop  es

           mov  di,offset tmp
           add  si,3
           mov  cx,9
contl:     cld
           lodsb
           cmp al,0
           jz  lcomp
           stosb
           inc  cx
           jmp  contl
lcomp:     inc cx
           stosb
           mov  si,offset tmp0
           pop  di
           push di
           repz movsb
           pop  ax
           pop  si
           pop  di
           pop  cx
           pop  es
           pop  ds
           popf
           ret
conv       endp
conv1      proc
           pushf
           push ds
           push es
           push cx
           push di
           push si

           mov  di,si
           sub  di,6
           push cs
           pop  ds
           push cs
           pop  es
           mov  cx,64
           cld
           repz movsb

           pop  si
           pop  di
           pop  cx
           pop  es
           pop  ds
           popf
           ret
conv1      endp

;********************************************************
; BEGIN
;********************************************************

begin:
          pushf
          push ax
          push bx
          push cx
#         push dx
          push si
          push di
          push bp
          push ds
          push es

          xor  ax,ax
          mov  es,ax
!         cmp  cs:reset,1234h                      ; Reset by me
#         jz   closeco
          cmp  es:[472h],1234h                     ; jmp ffff:0000
          jz   gcl
#         cmp  word ptr cs:mark,3412h              ; jmp ffff:0000
;         jz   gcl
closeco:  mov  dx,1f7h
!         mov  al,0
#         out  dx,al
!
gcl:      cli
          mov  bx,es:word ptr [9*4]
          mov  cs:int9off,bx                       ;int 9H
          mov  bx,es:word ptr [9*4+2]
          mov  cs:int9seg,bx
          mov  es:word ptr [4*9h],offset int9      ;int 9h
          mov  es:word ptr [4*9h+2],cs
          sti
          push cs
          pop  ds
          push cs
          pop  es
          call cls                      ;Clear Screen
          mov  ah,2
          mov  bh,0
          mov  dx,0
          int  10h
disba:
          mov  si,offset back
          mov  bl,3
          call dismess
          mov  ah,2
          mov  bh,0
          mov  dx,0
          int  10h
          mov  si,offset verm
showver:  mov  bl,1fh                  ;0ch
          call dismess                 ;Show Rights Message
checkhd:  call rcmos
          cmp  cs:cmos1[9],0
          jz   detecthd
          jmp  endd
detecthd: call waitbusy
          mov  dx,1f6h
          mov  al,0a0h
          out  dx,al
          inc  dx
          mov  al,10h
          out  dx,al
          call waitbusy
          in   al,dx
          cmp  al,50h
          jnz  nohd
          mov  dx,1f6h
          mov  al,0a0h
          out  dx,al
          inc  dx
          mov  al,0ech
          out  dx,al
          call waitr
          mov  dx,1f0h
          in   ax,dx
          in   ax,dx
          mov  cs:cylinder,ax
          mov  cs:lzone,ax
          in   ax,dx
          in   ax,dx
          mov  cs:head,al
          in   ax,dx
          in   ax,dx
          in   ax,dx
          mov  cs:secter,al
          mov  cs:wpcoml,0
          mov  cs:wpcom,-1
          mov  cs:cmos1[9],47
          mov  cs:cmos1[1],0bbh
          mov  cs:cmos1[2],0f0h
          call checksum
          mov  cx,48+64
          mov  si,offset cmos1
          mov  di,offset cmos
          cld
          repz movsb
          call wcmos
          jmp  diswc
nohd:
          mov  ah,2
          mov  bh,0
          mov  dx,0700h
          int  10h
          mov  si,offset nohdm
showno:   mov  bl,08fh
          call dismess
          call hidecur
          call s2872
          jmp  install2

endd:     push es
          mov  word ptr cs:data_4,0
	  xor  cx,cx		
	  mov  ah,8
	  mov  dl,0
	  int  13h
	  jc   loc_8
	  cmp  cx,4f0fh
	  jne  loc_8	
	  mov  cs:data_4,1
loc_8:
	  xor  cx,cx	
	  mov  ah,8
	  mov  dl,1
	  int  13h	
	  jc   loc_9		
	  cmp  cx,4f0fh
	  jne  loc_9		
	  mov  cs:data_4+1,1
loc_9:
          xor  ax,ax
          mov  dx,80h
          int  13h
          pop  es
!         mov  ax,0201h                    ; Dynamic setup
#         mov  bx,offset mark
#         mov  cx,1
!         mov  dx,80h
!
#         int  13h
          mov  ax,word ptr cs:[sect+1c4h]  ; endcl  cylinder_lo
          push ax
          mov  al,cs:[sect+1c3h]           ; enddh  head
          push ax
          mov  ax,0
          cmp  word ptr cs:[sect+1d3h],ax
          jnz  readpara
          mov  cs:onedisk,1
          jmp  readpar2
readpara: mov  cs:onedisk,0
readpar2: mov  ax,0201h
#         mov  bx,offset mark
#         mov  cx,3
!         mov  dx,80h
!
#         int  13h

          cmp  word ptr cs:mark,3412h
          jnz  disnos
          jmp  setaddr

disnos:   mov  si,offset nosetupm
shownos:  mov  ah,2
          mov  bh,0
          mov  dx,0700h
          int  10h
          mov  bl,08eh
          call dismess
          call hidecur
          call s2872
          push cs
          pop  ds
          push cs
          pop  es

          mov  ax,0201h
          mov  bx,offset sect
!         mov  cx,1
#         mov  dx,80h
!
#         int  13h
          mov  al,cs:[sect+1c4h]           ; endcl  cylinder_lo
          mov  cs:[sect+126],al            ;
          mov  al,cs:[sect+1c5h]           ; endch  cylinder_hi
          mov  cs:[sect+127],al
;         mov  al,cs:[sect+1beh]           ; enddl  boot mark 80h
;         mov  cs:[sect+128],al
          mov  al,cs:[sect+1c3h]           ; enddh  head
          mov  cs:[sect+129],al
          cld
          mov  si,offset setsap
          mov  di,offset sect
          mov  cx,14
          repz movsb
          mov  byte ptr cs:[di+130-14],0           ; Display Type
          mov  word ptr cs:[di+131-14],0ca8h       ; Protect Screen Time
          mov  byte ptr cs:[di+133-14],0f5h        ; 253 Function Selected
          mov  al,0ffh
          mov  di,offset sect+133+1
          mov  cx,14
          cld
stosbs:   stosb
          loop stosbs
          call rcmos
          cld
          mov  si,offset cmos1
          mov  di,offset sect+14
          mov  cx,128-16
#         repz movsb
!         mov  ax,0301h
#         mov  bx,offset sect
#         mov  cx,3
!         mov  dx,80h
!         int  13h
#
#         mov  dx,1f7h
!
          mov  al,0
!         out  dx,al

!         mov  ax,0201h                  ; 97/10/23
#         mov  bx,offset mark            ; 97/10/23
#         mov  cx,3                      ; 97/10/23
!         mov  dx,80h                    ; 97/10/23
!
#         int  13h                       ; 97/10/23

;          xor  ax,ax                      97/10/23
;          mov  es,ax                      97/10/23
;          mov  es:[472h],1234h            97/10/23
;          mov  cs:reset,1234h             97/10/23
;          db   0eah,0,0,0ffh,0ffh         97/10/23
setaddr:  pop  ax                          ;
          mov  cs:[sect+126],al            ;98/03/08
          mov  cs:[sect+127],ah            ;98/03/08
          pop  ax                          ;
          mov  cs:[sect+129],al            ;

          mov  cs:flag2,1
          mov  cs:sflag1,0
          mov  cs:sflag2,0
          mov  cs:count,0

testcpu:  pushf
          push ds
          mov  ax,0
          push ax
          popf
          pushf
          pop  ax
          and  ax,0f000h
          cmp  ax,0f000h
          jnz  ccls
          mov  ax,40h
          mov  ds,ax
          mov  ax,1eh
          mov  di,1ah
          mov  [di],ax
          mov  di,1ch
          mov  [di],ax
          mov  di,80h
          add  ax,32
          mov  [di],ax
          mov  dx,21h
          in   al,dx
          and  al,0fdh
          out  dx,al
ccls:     pop  ds
          popf
          test cs:funcf,4
          jz   chide
          mov  ah,2
          mov  bh,0
          mov  dx,0700h
          int  10h
          inc  dl
          mov  si,offset mes1
show2:    mov  bl,8ch
          call dismess
chide:    call hidecur
          call s2872
          jc   password
          jmp  install
password: cmp  cs:pass,0
          jnz  movtime
          jmp  install2
movtime:  mov  cs:time,0
passwordl:cmp  cs:time,3
          jnz  intime
          mov  ah,2
          mov  bh,0
          mov  dx,0200h
          int  10h
          mov  si,offset errorpass
          mov  bl,8eh                  ;0ch
          call dismess                 ;Show Rights Message
          call hidecur
          call s2872
          jmp  install
intime:   inc  cs:time
          call cls
          mov  ah,2
          mov  bh,0
          mov  dx,0
          int  10h
          mov  si,offset disp
          mov  cx,15
show:     mov  ah,9
          mov  al,20h
          mov  bl,0bh
          push cx
          mov  cx,1
          int  10h
          pop  cx
          mov  ah,0eh
          mov  bx,7
          cld
          lodsb
          int  10h
          loop show
          mov  cx,6
          mov  di,offset enter
          mov  bl,byte ptr cs:[pass+1]
          and  bl,0f0h
ent:      mov  ah,0
          int  16h
          cmp  al,0dh
          jnz  check21
          cld
          stosb
          cmp  cx,6
          jnz  check2
          mov  cx,0
          jmp  check2
check21:  call encr
          cld
          stosb
          push ax
          push bx
          push cx
          push dx
          push es
          push ds
          mov  ah,9
          mov  al,20h
          mov  cx,1
          mov  bh,0
          mov  bl,0fh
          int  10h
          pop  ds
          pop  es
          pop  dx
          pop  cx
          pop  bx
          pop  ax

          mov  bl,al
          mov  ah,0eh
          mov  al,'*'
          int  10h
          loop ent
check2:   mov  bl,cl
          mov  cl,6
          sub  cl,bl
          mov  al,byte ptr cs:[pass]
          cmp  al,cl
          jz   movsi
          jmp  passwordl
movsi:    mov  si,offset pass+2
          mov  di,offset enter
          cld
          repz cmpsb
          jz   xorax
          jmp  passwordl
xorax:
          mov  ah,2
          mov  bh,0
          mov  dx,0200h
          int  10h
          mov  si,offset opencard
          mov  bl,8eh                  ;0ch
          call dismess                 ;Show Rights Message
          call hidecur
          call s2872
          cli
          xor  ax,ax
          mov  es,ax
          mov  ax,cs:int9off
          mov  es:word ptr [9*4],ax
          mov  ax,cs:int9seg
          mov  es:word ptr [9*4+2],ax
          sti
          jmp  install2
install:  cmp  word ptr cs:mark,3412h
          jz   readok
          jmp  setup
readok:   mov  si,offset cmos1
!         mov  di,offset cmos           ;+3
          mov  cx,48+64
          cld
cmpsb0:
#
!         repz cmpsb
#         jz   setup
!         mov  ax,48+64-1
          sub  ax,cx
          mov  bl,8
          div  bl
          mov  bx,ax
          xor  bh,bh
          mov  al,cs:[bx+offset cm]
          mov  bl,1
          push cx
          xor  ch,ch
          mov  cl,7
          sub  cl,ah
shlbl:    shl  bl,1
          loop shlbl
          pop  cx
          test al,bl
          jnz  rescmos
dc:       jmp  cmpsb0
rescmos:  call wcmos
diswc:    mov  ah,2
          mov  bh,0
          mov  dx,0700h
          int  10h
          mov  si,offset cmosm
cmosl:    mov  bl,08eh
          call dismess
          call hidecur
          call s2872
          mov  dx,1f7h
          mov  al,0
          out  dx,al
          xor  ax,ax
          mov  es,ax
          mov  es:[472h],1234h
          mov  cs:reset,1234h
          db   0eah,0,0,0ffh,0ffh
;********************************************************
;
;                        SETUP
;
;********************************************************
setup:    xor  ax,ax
          mov  es,ax
          mov  bx,es:word ptr [04ch]
          mov  cs:int13off,bx
          mov  bx,es:word ptr [04eh]                ;int 13H
          mov  cs:int13seg,bx

#         xor  cs:int13off,65h
#
!         xor  cs:int13seg,34h

          mov  bx,es:word ptr [20h]
          mov  cs:int8off,bx                         ;int 8H
          mov  bx,es:word ptr [22h]
          mov  cs:int8seg,bx

;         mov  bx,es:word ptr [9*4]
;         mov  cs:int9off,bx                         ;int 9H
;         mov  bx,es:word ptr [9*4+2]
;         mov  cs:int9seg,bx

;************************  Set Interrupt ***************************

          cli
          mov    es:word ptr [4ch],offset int13      ;int 13H
          mov    es:word ptr [4eh],cs
          mov    word ptr es:[20h],offset int8h      ;int 8h
          mov    word ptr es:[22h],cs
;         test   cs:funcf,1
;         jz     goout
;         mov    es:word ptr [4*9h],offset int9      ;int 9h
;         mov    es:word ptr [4*9h+2],cs
          sti

;**************************  Initialize  ******************************
goout:    push   cs
          pop    ds
          push   cs
          pop    es
          mov    cs:in8,0
          mov    cs:f12,0
          mov    cs:f4f,0
          mov    cs:in9,0
          mov    cs:cgflag,0
          mov    cs:reset,0
          xor    al,al
          cld
          mov    di,offset tmp0
          mov    cx,405
          rep    stosb
          mov    cx,9
          mov    si,offset ztmp0
          mov    di,offset tmp0
          rep    movsb
          mov    cx,9
          mov    si,offset zsdrive
          mov    di,offset sdrive
          rep    movsb
          mov    cx,3
          mov    si,offset zddrive
          mov    di,offset ddrive
          rep    movsb

;***********************  install2  ****************************

install2: call   cls
          pop    es
          pop    ds
          pop    bp
          pop    di
          pop    si
          pop    dx
          pop    cx
          pop    bx
          pop    ax
          popf
          retf

;*************************  E N D  *****************************

cls       proc
          push ax
          push bx
          push cx
          push dx
;         mov ax,0700h
;         mov bh,7
;         mov ch,0
;         mov cl,0
;         mov dh,24
;         mov dl,79
;         int 10h
          mov ax,0003h
          int 10h
          pop dx
          pop cx
          pop bx
          pop ax
          ret
cls       endp
s2872     proc
          push    ax
          push    bx
          push    cx
          push    ds
          mov     ax,0
          mov     ds,ax
          mov     bx,word ptr ds:[46ch]
          mov     cx,2000h
el:       loop    el
s287c:    mov     ah,1
          int     16h
          jnz     presskey
          mov     cx,word ptr ds:[46ch]
cont:     sub     cx,bx
          jz      l286
          cmp     cx,18*3
          ja      ret2
          jmp     s287c
presskey: mov     ah,0
          int     16h
          cmp     ax,011bh
          jnz     ret2      ;       s287c
ret1:     stc
          jmp     ret3
ret2:     clc
          jmp     ret3
l286:     mov     cx,6000h
rek:      mov     ah,1
          int     16h
          jnz     presskey
          loop    rek
          clc
ret3:     pop     ds
          pop     cx
          pop     bx
          pop     ax
return:   ret
s2872     endp

rcmos     proc
          mov    si,16
read1:    mov    ax,si
          out    70h,al
          in     al,71h
          mov    cs:cmos1[si-16],al
          inc    si
          cmp    si,64+64
          jnz    read1
          ret
rcmos     endp

wcmos     proc
          mov    si,16
read2:    mov    ax,si
          out    70h,al
          mov    al,cs:cmos[si-16]
          out    71h,al
          inc    si
          cmp    si,64+63
          jnz    read2
          ret
wcmos     endp
waitr     proc
          push   ax
          push   dx
          mov    dx,1f7h
inext2:   in     al,dx
          cmp    al,58h
          jnz    inext2
          pop    dx
          pop    ax
          ret
waitr     endp
waitbusy  proc
          push   ax
          push   dx
          mov    dx,1f7h
inext:    in     al,dx
          cmp    al,80h
          ja     inext
          pop    dx
          pop    ax
          ret
waitbusy  endp
checksum  proc
          xor    bx,bx
          xor    ax,ax
          mov    cx,30
          mov    si,offset cmos1
llod:     lodsb
          add    bx,ax
          loop   llod
          xchg   bh,bl
          mov    cs:checksums,bx
          ret
checksum  endp
;************************************************************************
;
;                      PassWord Encrypt Procedure
;
;************************************************************************
;  Input  al,bl
;  Output bl
;************************************************************************
encr      proc
mark1:    test  bl,063h
!         jpe   mark2
#         stc
mark2:    rcr   bl,1
!         dec   al
!         jnz   mark1
!         mov   al,bl
#         ret
encr      endp

;*****************************************************************
;  input bl -- color
;        ds:si -- buffer offset
;******************************************************************
dismess   proc
          push ax
          push bx
          push cx
          cld
loopd:    lodsb
          dec  si
          cmp  al,0
          jz   outdisp
          cmp  al,0dh
          jz   now
          cmp  al,0ah
          jz   now
          mov  ax,0920h
          mov  cx,1
          mov  bh,0
          int  10h
now:      mov  ah,0eh
          mov  bh,0
          lodsb
          int  10h
          jmp  loopd
outdisp:  pop  cx
          pop  bx
          pop  ax
          ret
dismess   endp
hidecur   proc
          push ax
          push bx
          push dx
          mov  ah,2
          mov  bh,0
          mov  dx,0ffffh
          int  10h
          pop  dx
          pop  bx
          pop  ax
          ret
hidecur   endp
setflag0 proc
         push es
         push ax
         push bx

         mov  ax,0
         mov  es,ax
         mov  ax,es:word ptr [4]
         mov  cs:int1off,ax
         mov  bx,ax
         mov  ax,es:word ptr [6]
         mov  cs:int1seg,ax

         mov  es,ax
         mov  al,byte ptr es:[bx]
         mov  cs:fbyte,al
         mov  byte ptr es:[bx],0cfh

notrace: pop  bx
         pop  ax
         pop  es
         ret
setflag0 endp
setflag1 proc
         push es
         push ax
         push bx
         mov  bx,cs:int1off
         mov  ax,cs:int1seg
         mov  es,ax
         mov  al,cs:fbyte
         mov  byte ptr es:[bx],al
         pop  bx
         pop  ax
         pop  es
         ret
setflag1 endp
call13    proc

          pushf
          push ax
          push cx
          push si
          push di
#         push ds
          push es
          call setflag0


          push cs
          pop  ds
          push cs
#         pop  es
!         in   al,21h
#         mov  cs:por21,al
#         or   al,2
          out  21h,al

          mov  si,offset pr
          mov  di,offset pr2
          cld
lr:       lodsb
          cmp  al,0
          jz   good
#
#         xor  al,0c2h
!
          stosb
          jmp  lr
good:
!         xor  cs:int13off,65h
#
!         xor  cs:int13seg,34h

          pop  es
          pop  ds
          pop  di
          pop  si
#         pop  cx
          pop  ax
          popf
#
!         call pr20
#         pushf
          push ax
          push cx
          push si
          push di
          push ds
          push es

          push cs
          pop  ds
          push cs
          pop  es
          mov  di,offset pr2
          mov  cx,7
          cld
          repz stosb
          mov  al,cs:por21
!         out  21h,al

!         xor  cs:int13off,65h
#
!         xor  cs:int13seg,34h

          call setflag1
          pop  es
          pop  ds
          pop  di
          pop  si
          pop  cx
          pop  ax
          popf
          ret
call13    endp
savec     proc
          push  es
          push  ax
          xor   ax,ax
          mov   es,ax
          mov   ax,word ptr es:[4]
          mov   cs:int1off,ax
          mov   ax,word ptr es:[4+2]
          mov   cs:int1seg,ax
          mov   ax,word ptr es:[3*4]
          mov   cs:int3off,ax
          mov   ax,word ptr es:[3*4+2]
          mov   cs:int3seg,ax
          cli
          mov   word ptr es:[4],offset int1
          mov   word ptr es:[4+2],cs
          mov   word ptr es:[3*4],offset int1
          mov   word ptr es:[3*4+2],cs
          sti
popax:    pop   ax
          pop   es
          ret
savec     endp
resvec    proc
          pushf
          push  es
          push  ax
          xor   ax,ax
          mov   es,ax
          cli
          mov   ax,cs:int1off
          mov   word ptr es:[4],ax
          mov   ax,cs:int1seg
          mov   word ptr es:[4+2],ax
          mov   ax,cs:int3off
          mov   word ptr es:[3*4],ax
          mov   ax,cs:int3seg
          mov   word ptr es:[3*4+2],ax
          sti
          pop   ax
          pop   es
          popf
          ret
resvec    endp
int1:     iret
into:     mov  ax,4c00h
          int  21h

org       2000h
mark      db   11h,22h,33h,0,0,0
pass      db   8 dup(?)
cmos      db   128-16 dup (?)
endcl     db   ?
endch     db   ?
enddl     db   ?
enddh     db   ?
sctype    db   3
scount    dw   180
funcf     db   ?
cm        db   14 dup (0)
          db   512-120 dup(0)
data_4	  db   ?
          db   ?
off       dw   ?
size      dw   ?
enter     db   '        '
time      db   0
cmos1     db   11 dup (?)
cylinder  dw   ?
head      db   ?
wpcom     dw   ?
wpcoml    db   ?
lzone     dw   ?
secter    db   ?
          db   10 dup(?)
checksums dw   ?
          db   16 dup(?)
          db   128-48 dup(?)
flag2     db   0
count     dw   0
sflag     dw   0
sflag1    db   0
sflag2    db   0
int13off  dw   ?
int13seg  dw   ?
int9off   dw   ?
int9seg   dw   ?
int8off   dw   ?
int8seg   dw   ?
in8       db   0
por21     db   ?
pr20:
pr2        db   7 dup (?)
sect       db  10 dup (?)
int21off   dw  ?
int21seg   dw  ?
vax        dw  ?
vax2       dw  ?
vcx        dw  ?
vcx2       dw  ?
vcx3       dw  ?
vdx        dw  ?
ves        dw  ?
vdi        dw  ?
f12        db  0
f4f        db  0
tmp0       db  'C:\HDPRT\'
tmp        db  64 dup(0)
sdrive     db  'D:\HDPRT\'
spath      db  64 dup(0)
ddrive     db  'D:\'
dpath      db  64 dup(0)
fname      db  64 dup(0)
fname2     db  64 dup(0)
fname3     db  64 dup(0)
vvvc       dw  ?
in9        db  0
cgflag     db  0
pro        db  5 dup (?)
s09off     dw  ?
s09seg     dw  ?
vbx        dw  ?
vccx       dw  ?
int1off    dw  ?
int1seg    dw  ?
int3off    dw  ?
int3seg    dw  ?
int00off   dw  ?
int00seg   dw  ?
reset      dw  ?
fbyte      db  ?
onedisk    db  ?
code       ends
           end flag
