extern printf
extern scanf
global main

section .data
nomes: times 600 db 0x0
notas1: times 40 dd 0.0
notas2: times 40 dd 0.0
notas3: times 40 dd 0.0
medias: times 40 dd 0.0

qtde_alunos: dd 0x0

vetor_divisor: dd 3.0, 3.0, 3.0, 3.0 ; Vetor usado durante a divisão para obter a média

texto_menu: db 0xa, 'Digite a opcao desejada:', 0xa, '1. Incluir notas de aluno (max. 40 alunos)', 0xa, '2. Exibir medias da turma', 0xa, '3. Sair do programa', 0xa, 0x0
texto_inserir_nome: db 0xa, 'Nome (max. 14 caracteres): ', 0xa, 0x0
texto_limite_atingido: db 0xa, 'Nao e possivel inserir mais alunos. Limite maximo atingido', 0xa, 0x0
texto_inserir_nota1: db 'Insira a primeira nota:', 0xa, 0x0
texto_inserir_nota2: db 'Insira a segunda nota:', 0xa, 0x0
texto_inserir_nota3: db 'Insira a terceira nota:', 0xa, 0x0
texto_nova_linha: db 0xa, 0x0

scan_int: db '%d', 0x0
print_int: db '%d', 0xa, 0x0
scan_string: db '%s', 0x0
print_string: db '%s', 0xa, 0x0
scan_float: db '%f', 0x0
print_float: db '%.2f', 0xa, 0x0

section .text
main:
  push ebp
  mov ebp, esp

exibir_menu:
  push texto_menu
  call printf
  add esp, 4

  ; Lê opção do menu para ebp-4
  sub esp, 4
  lea eax, [ebp-4]

  push eax
  push scan_int
  call scanf
  add esp, 8

  ; Pula para a opção selecionada
  mov eax, [ebp-4]
  sub eax, 1
  je opcao1

  mov eax, [ebp-4]
  sub eax, 2
  je opcao2

  mov eax, [ebp-4]
  sub eax, 3
  je opcao3

  jmp exibir_menu

; inserir um novo aluno e suas notas
opcao1:
  mov ebx, [qtde_alunos]
  cmp ebx, 40
  jge limite_atingido

  push texto_inserir_nome
  call printf
  add esp, 4

  mov ecx, nomes
  
  ; eax: endereço para nome do aluno atual
  ; ebx: indice do aluno atual
  mov eax, 15
  mul ebx
  add eax, ecx

  ; lê nome
  push eax
  push scan_string 
  call scanf
  add esp, 8

  push texto_inserir_nota1
  call printf
  add esp, 4

  mov ecx, notas1

  ; eax: endereço do float para inserir a nota
  mov eax, 4
  mul ebx
  add eax, ecx

  push eax
  push scan_float
  call scanf
  add esp, 8

  ; nota 2
  push texto_inserir_nota2
  call printf
  add esp, 4

  mov ecx, notas2

  mov eax, 4
  mul ebx
  add eax, ecx

  push eax
  push scan_float
  call scanf
  add esp, 8

  ; nota 3
  push texto_inserir_nota3
  call printf
  add esp, 4

  mov ecx, notas3

  mov eax, 4
  mul ebx
  add eax, ecx

  push eax
  push scan_float
  call scanf
  add esp, 8

  ; incrementa qtde_alunos
  mov eax, [qtde_alunos]
  inc eax
  mov [qtde_alunos], eax

  jmp exibir_menu

limite_atingido:
  push texto_limite_atingido
  call printf
  add esp, 4
  
  jmp exibir_menu

opcao2:  
  push texto_nova_linha
  call printf

  ; calcular as medias
  mov ecx, [qtde_alunos]
  push ecx
  call funcao_calcular_medias
  add esp, 4

  ; imprimir nome e media
  mov ebx, -1 ; contador
loop_imprimir_medias:
  inc ebx
  mov ecx, [qtde_alunos]
  cmp ebx, ecx
  je fim_loop_imprimir_medias
  
  ; eax: endereço do nome do aluno de índice ebx
  mov eax, 15
  mul ebx
  add eax, nomes

  ; imprimir nome
  push eax
  push print_string
  call printf
  add esp, 8

  ; eax: endereço da media do aluno
  mov eax, 4
  mul ebx
  add eax, medias

  ; imprimir media
  fld DWORD[eax]
  sub esp, 8
  fstp QWORD[esp]
  push print_float
  call printf
  add esp, 12

  jmp loop_imprimir_medias

fim_loop_imprimir_medias:
  jmp exibir_menu

; sair do programa
opcao3:
  mov esp, ebp
  pop ebp
  ret

  mov eax, 1
  xor ebx, ebx
  int 0x80

; parâmetro: DWORD quantidade de alunos
funcao_calcular_medias:
  push ebp
  mov ebp, esp

  ; ecx: offset para a última nota do último aluno
  mov ecx, [ebp+8]
  sub ecx, 1
  xor edx, edx
  mov eax, 4
  mul ecx

  ; ebx: contador e offset para as proximas quatro notas a serem calculadas
  mov ebx, -16
loop_calcular_medias:
  add ebx, 16
  cmp ebx, ecx 
  jg fim_loop_calcular_medias
   
  movups xmm1, OWORD[notas1 + ebx]
  movups xmm2, OWORD[notas2 + ebx]
  movups xmm3, OWORD[notas3 + ebx]
  
  pxor xmm0, xmm0

  ; somar notas e guardar em xmm0
  addps xmm0, xmm1
  addps xmm0, xmm2
  addps xmm0, xmm3

  ; dividir o somatorio por 3 e obter a média em xmm0
  movups xmm4, OWORD[vetor_divisor]
  divps xmm0, xmm4

  ; guardar no vetor de medias
  movups OWORD[medias + ebx], xmm0

  jmp loop_calcular_medias

fim_loop_calcular_medias:
  mov esp, ebp
  pop ebp
  ret

