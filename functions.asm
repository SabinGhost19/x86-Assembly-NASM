
string:

    ; esi -> sir
    ; return length in eax
    .length:
        push ebp
        mov ebp,esp

        push ebx
        push ecx
        push esi

        mov ebx, esi

        .lengthLoop:
            mov cl, byte[esi]
            inc esi
            cmp cl, byte 0
            jnz .lengthLoop
        
        sub esi, ebx
        mov eax, esi
        sub eax, 1

        pop esi
        pop ecx
        pop ebx

        mov esp, ebp
        pop ebp
        ret

    ; trebuie inainte de apelare sa ai in esi -> sirul
    .print:
        push ebp
        mov ebp,esp

        push eax
        push ebx
        push ecx
        push edx

        call .length

        mov edx, eax
        mov eax, 4
        mov ebx, 1
        mov ecx, esi
        int 0x80
        
        pop edx
        pop ecx
        pop ebx
        pop eax

        mov esp, ebp
        pop ebp
        ret

    ; Takes eax as input
    .PrintNumberEndl:
        push ebp
        mov ebp, esp
        push eax

        call .PrintNumber

        mov eax, 0xa
        call char.Print

        pop eax
        mov esp, ebp
        pop ebp
        ret

    ; Takes ecx as input number, any length
    .PrintNumber:
        push ebp
        mov ebp, esp

        push eax
        push ebx
        push ecx
        push edx
        push esi

        mov esi, buffer
        call number.itoa
        mov esi, eax
        call string.print
        
        pop esi
            pop edx
            pop ecx
            pop ebx
            pop eax

        mov esp, ebp
        pop ebp
        ret

    ; Takes the string from esi and prints it with newline
    .PrintEndl:
        push ebp
        mov ebp, esp

        call .print
        call char.NewLine

        mov esp, ebp
        pop ebp
        ret
    ; Functia reverse_string:
    ; Inverseaza un sir de caractere dat
    ; Intrari:
    ;   esi - pointer la sirul de caractere de inversat
    ; Iesiri:
    ;   Sirul este inversat in memorie, nu returneaza nimic

    .reverse_string:
        push ebx             ; Salvam registrul EBX pe stiva
        push edi             ; Salvam registrul EDI pe stiva
        push ecx             ; Salvam registrul ECX pe stiva

        ; Determinarea lungimii sirului
        mov edi, esi         ; Mutam pointerul de inceput in EDI
        xor ecx, ecx         ; Resetam ECX pentru a numara lungimea

        .find_end:
            cmp byte [edi], 0    ; Cautam terminatorul de sir (caracterul 0)
            je .found_end        ; Daca l-am gasit, iesim din bucla
            inc edi              ; Trecem la urmatorul caracter
            inc ecx              ; Incrementam contorul de lungime
            jmp .find_end

        .found_end:
            dec edi              ; Setam EDI pentru a indica ultimul caracter (inainte de terminator)

            ; Inversarea sirului
        .reverse_loop:
            cmp esi, edi         ; Verificam daca pointerele s-au intalnit sau s-au incrucisat
            jge .done_reversing  ; Daca da, terminam inversarea

            mov al, [esi]        ; Mutam caracterul de la inceputul sirului in AL
            mov bl, [edi]        ; Mutam caracterul de la sfarsitul sirului in BL
            mov [esi], bl        ; Punem BL la inceputul sirului
            mov [edi], al        ; Punem AL la sfarsitul sirului

            inc esi              ; Avansam pointerul de la inceput spre mijloc
            dec edi              ; Avansam pointerul de la sfarsit spre mijloc
            jmp .reverse_loop    ; Repetam bucla

    .done_reversing:
        pop ecx              ; Restauram registrul ECX
        pop edi              ; Restauram registrul EDI
        pop ebx              ; Restauram registrul EBX
        ret                  ; Revenim din functie
; int
number:
    ; in ecx punem numarul
    ; in esi bufferul in care o sa avem arrayul format
    ; intoarce rezultatul in eax
    .itoa:
        push ebp
        mov ebp, esp

        push ebx
        push ecx
        push edx
        push edi
        push esi

        mov eax, ecx ; copiez in eax numarul 
        mov edi, esi ; edi reprezinta arrayul in care pun numarul 
        add esi, 10
        mov byte [edi], 0

        .itoa_loop:
            xor edx, edx
            mov ebx, 10
            div ebx ; imparte eax la ebx (adica impart numarul la 10), pastrez catul in eax si restul in edx

            add dl, 0x30

            dec edi
            mov [edi], dl
            
            test eax, eax
            jnz .itoa_loop 

        mov eax, edi

        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx

        mov esp, ebp
        pop ebp
        ret
    
    ; Takes esi as parameter
    ; Returns the number in eax
    .atoi:
        push ebp
        mov ebp, esp

        push ebx
        push ecx
        push edx

        ; First number is already in eax
        xor eax, eax
        mov al, byte [esi]

        ; Convert to number 
        sub al, 0x30

        ; Check if the number is only 1 char long
        cmp [esi + 1], byte 0
        je ._atoiExitSingle

        mov ecx, 1
        ._atoiLoop:
            mov bl, [esi + ecx]

            ; Multiplicate the number by 10
            mov edx, 10
            mul edx

            ; Add the new number to the value
            add eax, ebx
            sub eax, 0x30

            inc ecx

            cmp [esi + ecx], byte 0
            je ._atoiExit

            cmp [esi + ecx], byte 0
            jne ._atoiLoop

        jmp ._atoiExit
        
        ._atoiExitSingle:
            mov [esi], al

        ._atoiExit:
            pop edx
            pop ecx
            pop ebx

        mov esp, ebp
        pop ebp
        ret
        ; Funcția int_to_hex: transformă un număr din baza 10 în baza 16
    ; Intrări:
    ;   eax - numărul de convertit
    ;   edi - pointer la bufferul unde se va scrie rezultatul
    .int_to_hex:
        push ebp
        mov ebp, esp

        push esi
        push ecx
        push ebx

        mov ecx, 8            ; fiecare întreg în baza 16 poate avea până la 8 caractere hex
        mov esi, edi

        .convert_loop_hex:
            mov ebx, eax
            and ebx, 0xF          ; extragem cele mai joase 4 biți (o cifră hex)

            ; Convertim cifra în caracter ASCII
            cmp ebx, 9
            jbe .convert_to_number ; dacă cifra este între 0 și 9
            add ebx, 'A' - 10      ; convertim cifrele 10-15 în 'A'-'F'
            jmp .store_digit

        .convert_to_number:
            add ebx, '0' ; convertim cifrele 0-9 în '0'-'9'

        .store_digit:
            mov [esi], bl ; stocăm cifra convertită în buffer
            inc esi       ; trecem la următoarea poziție
            shr eax, 4    ; trecem la următoarea cifră hex în numărul original
            loop .convert_loop_hex

        pop ebx
        pop ecx
        pop esi
        mov esp, ebp
        pop ebp
        ret

    ; Functia int_to_bin:
    ; Converteste un intreg din baza 10 in binar
    ; Modifica primul ecx din functie ca sa scrii pe cati biti afisezi in binar
    ;                                   maxim 31
    ; Intrari:
    ;   eax - numarul de convertit
    ;   edi - pointer la bufferul unde se va scrie rezultatul
    ; Iesiri:
    ;   Niciun rezultat specific. Bufferul contine sirul binar (32 de caractere).

    .int_to_bin:
        push ebx             ; Salvam registrul EBX pe stiva
        push ecx             ; Salvam registrul ECX pe stiva
        push edx             ; Salvam registrul EDX pe stiva

        mov ecx, 8          ; Setam ECX la 31 (indexul pentru cel mai semnificativ bit)
        
        .convert_loop:
            cmp ecx, -1          ; Verificam daca am terminat bucla (indexul a ajuns la -1)
            jl .done             ; Daca da, iesim din bucla

            xor edx, edx         ; Resetam EDX (restul)
            mov ebx, 2           ; Pregatim pentru impartire la 2
            div ebx              ; EAX = EAX / 2, restul in EDX (EDX va fi 0 sau 1)

            ; Convertim restul (EDX) in caracter ASCII ('0' sau '1')
            add dl, '0'          ; Adaugam '0' pentru a transforma 0 sau 1 in '0' sau '1'
            mov [edi + ecx], dl  ; Stocam caracterul in bufferul binar

            dec ecx              ; Decrementam indexul
            jmp .convert_loop    ; Repetam bucla

    .done:
        pop edx              ; Restauram registrul EDX
        pop ecx              ; Restauram registrul ECX
        pop ebx              ; Restauram registrul EBX
        ret                  ; Revenim din functie
    ; Takes two parameters, eax for the number, ecx for the power
    ; Returns in eax the value
    .pow:
        push ebp
        mov ebp, esp

        push ebx
        push ecx
        push edx

        mov ebx, eax
        mov eax, 1

        ._pLoop:
            mul ebx
            dec ecx

            cmp ecx, 0
            jne ._pLoop

        pop edx
        pop ecx
        pop ebx

        mov esp, ebp
        pop ebp
        ret
        
char:
    ; Print number from eax
    .PrintNumber:
        push ebp
        mov ebp, esp

        push eax
        push ebx
        push ecx
        push edx

        push eax
        add [ebp - 4 * 5], byte 0x30
        mov eax, 4
        mov ebx, 1
        lea ecx, [ebp - 4 * 5]
        mov edx, 1
        int 0x80

        add esp, 4

        pop eax
        pop edx
        pop ecx
        pop ebx
        pop eax

        mov esp, ebp
        pop ebp
        ret

    ; Print new line
    .NewLine:
        push ebp
        mov ebp, esp

        push eax

        mov eax, 0xa
        call .Print

        pop eax
        
        mov esp, ebp
        pop ebp
        ret

    ; Print char from eax
    .Print:
        push ebp
        mov ebp, esp

        push eax
        push ebx
        push ecx
        push edx

        push eax
        mov eax, 4
        mov ebx, 1
        lea ecx, [ebp - 4 * 5]
        mov edx, 1
        int 0x80

        add esp, 4

        pop eax
        pop edx
        pop ecx
        pop ebx
        pop eax

        mov esp, ebp
        pop ebp
        ret


; Parametrii:
;   esi - pointer la șirul de caractere de intrare
;   edi - pointer la vectorul de ieșire
; Returnează:
;   eax - numărul de elemente convertite

convert_to_int_vector:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    push ecx
    push edx

    xor eax, eax                ; Initializează contorul de elemente convertite

.loop: 
    cmp byte [esi], 0           ; Verifică dacă am ajuns la finalul șirului
    je .done                    ; Dacă da, termină

    cmp byte [esi], ' '         ; Verifică dacă caracterul curent este un spațiu
    je .skip_space              ; Dacă da, sari peste el

    xor ebx, ebx                ; Registru pentru numărul curent
    mov ecx, 1                  ; Setați ecx la 1 pentru numere pozitive (ecx va fi -1 pentru numere negative)

    cmp byte [esi], '-'         ; Verifică dacă caracterul curent este un semn minus
    jne .check_digit            ; Dacă nu, sari la verificarea cifrelor

    ; Gestionarea numerelor negative
    mov ecx, -1                 ; Setați ecx la -1 pentru numere negative
    inc esi                     ; Treci la următorul caracter

.check_digit:
    ; Conversia caracterelor în număr
    .number_loop:
        cmp byte [esi], ' '     ; Verifică dacă caracterul curent este un spațiu
        je .store_number        ; Dacă da, sari la stocarea numărului

        cmp byte [esi], 0       ; Verifică dacă am ajuns la finalul șirului
        je .store_number        ; Dacă da, sari la stocarea numărului
    
        sub byte [esi], '0'     ; Transformă caracterul ASCII în valoare numerică
        movzx edx, byte [esi]   ; Extinde valoarea pe 8 biți la 32 de biți în edx
        imul ebx, ebx, 10       ; ebx = ebx * 10
        add ebx, edx            ; Adaugă valoarea numerică curentă la ebx

        inc esi                 ; Treci la următorul caracter din șirul de intrare
        jmp .number_loop
    
    .store_number:
        imul ebx, ecx           ; Aplică semnul corect la număr (ebx = ebx * ecx)
        mov [edi], ebx          ; Stochează valoarea în vectorul de ieșire
        add edi, 4              ; Mută pointerul la următorul element din vectorul de ieșire
        inc eax                 ; Incrementează contorul de elemente convertite

    .skip_space:
        inc esi                 ; Treci la următorul caracter din șirul de intrare
        jmp .loop

.done:
    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret



; trebuie sa ai in edi -> vectorul de int
; trebuie sa ai un buffer -> alocat pentru afisarea unui numar(cu un numar maxim de caractere cate vrei tu)
; adica aloci un buffer in section .bss
; buffer resb 10 (sau nr max cat vrei)
; in ecx numarul de elemente
print_int_vector:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    push ecx
    push edx


    .loopAfisare:
        cmp ecx, 0
        je .doneAfisare

        mov eax, [edi]
        add edi, 4

        push ecx

        mov ecx, eax
        mov esi, buffer
        call number.itoa

        mov esi, eax
        call string.print
        mov eax,32;!!!!!!!!! modified
        call char.Print
        pop ecx

        dec ecx
        jmp .loopAfisare    

    .doneAfisare:

    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret


; in esi  vectorul 
; in ecx dimensiunea lui
bubble_sort:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    push ecx



.outer_loop:
    dec ecx
    jz .done

    mov edx, esi
    mov edi, ecx

.inner_loop:
    mov eax, [edx]            ; Load the current element
    mov ebx, [edx + 4]        ; Load the next element
    cmp eax, ebx
    jle .no_swap              ; If the current element <= next element, no swap needed

    ; Swap the elements
    mov [edx], ebx
    mov [edx + 4], eax

.no_swap:
    add edx, 4                ; Move to the next pair of elements
    dec edi
    jnz .inner_loop

    jmp .outer_loop

.done:
    pop ecx
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret




; Takes esi as parameter (string)
; Takes edi as parameter (destination)
; Takes eax as parameter (separator)
; Takes edx as parameter (offset)
; returns in edx last position to start from in vector
; returns in edi word until eax
strtok:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx

    ; Keep the separator in ebx
    xor ebx, ebx
    mov ebx, eax

    ; Get the length in eax
    call string.length

    ; Start from offset
    mov ecx, edx
    .loop:
        ; in bl is the ascii code for the separator
        cmp [esi + ecx], bl
        je .end

        cmp [esi + ecx], byte 0x00
        je .end

        push ebx
        mov bl, byte [esi + ecx]

        ; Offset for edi
        mov eax, ecx
        sub eax, edx

        mov [edi + eax], bl
        inc ecx

        pop ebx

        jmp .loop

    .end:
        ; Put 0x00 at the final so that we don t need to reset everytime edi
        mov eax, ecx
        sub eax, edx
        mov [edi + eax], byte 0x00

        ; For the next offset (Does NOT read the separator)
        inc ecx
        mov edx, ecx

    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret






%define SYS_EXIT     1
%define SYS_READ     3
%define SYS_WRITE    4
%define SYS_OPEN     5
%define SYS_CLOSE    6
 
%define O_RDONLY     0   ; Read-only mode
%define O_WRONLY     1   ; Write-only mode
%define O_RDWR       2   ; Read-write mode
%define O_CREATE      64  ; Create file if it does not exist
%define O_APPEND     1024 ; Append se foloseste impreuna cu write
%define O_TRUNCATE     512 ; Truncate

file:
    ; pui in esi numele fisierului
    ; in eax file descritor
    ; intoarce in eax file descriptor
    .fileOpen:
        push ebp
        mov ebp, esp

        push ebx
        push ecx
        push edx

        mov ecx, eax
        mov ebx, esi    
        mov eax, 0x05
        mov edx, 666o
        int 0x80

        pop edx
        pop ecx
        pop ebx

        mov ebp, esp
        pop ebp
        ret
    
    ; in esi sa am siru l pe care vr sa il scriu
    ; in eax file descriptor
    .fileWrite:
        push ebp
        mov ebp, esp

        push eax
        push ebx
        push ecx
        push edx

        mov ebx, eax ; file descriptor
        call string.length ; imi ia din esi si imi calculeaza lungimea sirului
        mov edx, eax ; lungimea in edx
        mov ecx, esi
        mov eax, 0x04 ; sys_write
        int 0x80

        pop edx
        pop ecx
        pop ebx
        pop eax

        mov ebp, esp
        pop ebp
        ret
    ; in eax citesc file descriptor
    ; in esi registrul in care citesc
    ; in edx cat citesc
    .fileRead:
        push ebp
        mov ebp, esp

        push ebx
        push ecx

        mov ebx, eax
        mov ecx, esi
        mov eax, 0x03 ; sys read
        int 0x80

        pop ecx
        pop ebx

        mov ebp, esp
        pop ebp
        ret


    ; Reads from the last file opened
    ; Takes edi as buffer to read
    .fileReadLine:
        push ebp
        mov ebp, esp

        push eax
        push ebx
        push ecx
        push edx
        push esi 
        push edi

        mov ecx, 0
        .readLoop:
            mov ebx, eax

            push eax
            push ecx

            mov eax, 3
            mov edx, 1
            lea ecx, [edi + ecx]
            int 0x80 ; sys call

            pop ecx
            pop eax

            cmp [edi + ecx], byte 0x0a ; Compare with newline
            je .endNl

            cmp [edi + ecx], byte 0x00 ; compare with endoffile
            je .end

            inc ecx

            jmp .readLoop

        .endNl:
            mov [edi + ecx], byte 0x00

        .end:

        pop edi 
        pop esi 
        pop edx
        pop ecx 
        pop ebx 
        pop eax

        mov esp, ebp
        pop ebp
        ret

    ; esi numele fisierului
    ; intoarce in eax file descriptor
    .fileCreate:
        push ebp
        mov ebp, esp

        push ebx
        push ecx
        
        mov eax, 0x08
        mov ebx, esi ; filename
        mov ecx, 666o ; toate permisiunile
        int 0x80

        pop ecx
        pop ebx

        mov ebp, esp
        pop ebp
        ret


