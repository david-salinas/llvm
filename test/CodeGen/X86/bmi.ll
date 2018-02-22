; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi | FileCheck %s --check-prefix=CHECK --check-prefix=BMI1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi,+bmi2 | FileCheck %s --check-prefix=CHECK --check-prefix=BMI2

declare i8 @llvm.cttz.i8(i8, i1)
declare i16 @llvm.cttz.i16(i16, i1)
declare i32 @llvm.cttz.i32(i32, i1)
declare i64 @llvm.cttz.i64(i64, i1)

define i8 @t1(i8 %x)   {
; CHECK-LABEL: t1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    orl $256, %eax # imm = 0x100
; CHECK-NEXT:    tzcntl %eax, %eax
; CHECK-NEXT:    # kill: def $al killed $al killed $eax
; CHECK-NEXT:    retq
  %tmp = tail call i8 @llvm.cttz.i8( i8 %x, i1 false )
  ret i8 %tmp
}

define i16 @t2(i16 %x)   {
; CHECK-LABEL: t2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntw %di, %ax
; CHECK-NEXT:    retq
  %tmp = tail call i16 @llvm.cttz.i16( i16 %x, i1 false )
  ret i16 %tmp
}

define i32 @t3(i32 %x)   {
; CHECK-LABEL: t3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntl %edi, %eax
; CHECK-NEXT:    retq
  %tmp = tail call i32 @llvm.cttz.i32( i32 %x, i1 false )
  ret i32 %tmp
}

define i32 @tzcnt32_load(i32* %x)   {
; CHECK-LABEL: tzcnt32_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntl (%rdi), %eax
; CHECK-NEXT:    retq
  %x1 = load i32, i32* %x
  %tmp = tail call i32 @llvm.cttz.i32(i32 %x1, i1 false )
  ret i32 %tmp
}

define i64 @t4(i64 %x)   {
; CHECK-LABEL: t4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntq %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.cttz.i64( i64 %x, i1 false )
  ret i64 %tmp
}

define i8 @t5(i8 %x)   {
; CHECK-LABEL: t5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    tzcntl %eax, %eax
; CHECK-NEXT:    # kill: def $al killed $al killed $eax
; CHECK-NEXT:    retq
  %tmp = tail call i8 @llvm.cttz.i8( i8 %x, i1 true )
  ret i8 %tmp
}

define i16 @t6(i16 %x)   {
; CHECK-LABEL: t6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntw %di, %ax
; CHECK-NEXT:    retq
  %tmp = tail call i16 @llvm.cttz.i16( i16 %x, i1 true )
  ret i16 %tmp
}

define i32 @t7(i32 %x)   {
; CHECK-LABEL: t7:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntl %edi, %eax
; CHECK-NEXT:    retq
  %tmp = tail call i32 @llvm.cttz.i32( i32 %x, i1 true )
  ret i32 %tmp
}

define i64 @t8(i64 %x)   {
; CHECK-LABEL: t8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    tzcntq %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.cttz.i64( i64 %x, i1 true )
  ret i64 %tmp
}

define i32 @andn32(i32 %x, i32 %y)   {
; CHECK-LABEL: andn32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl %esi, %edi, %eax
; CHECK-NEXT:    retq
  %tmp1 = xor i32 %x, -1
  %tmp2 = and i32 %y, %tmp1
  ret i32 %tmp2
}

define i32 @andn32_load(i32 %x, i32* %y)   {
; CHECK-LABEL: andn32_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl (%rsi), %edi, %eax
; CHECK-NEXT:    retq
  %y1 = load i32, i32* %y
  %tmp1 = xor i32 %x, -1
  %tmp2 = and i32 %y1, %tmp1
  ret i32 %tmp2
}

define i64 @andn64(i64 %x, i64 %y)   {
; CHECK-LABEL: andn64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp1 = xor i64 %x, -1
  %tmp2 = and i64 %tmp1, %y
  ret i64 %tmp2
}

; Don't choose a 'test' if an 'andn' can be used.
define i1 @andn_cmp(i32 %x, i32 %y) {
; CHECK-LABEL: andn_cmp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl %esi, %edi, %eax
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %notx = xor i32 %x, -1
  %and = and i32 %notx, %y
  %cmp = icmp eq i32 %and, 0
  ret i1 %cmp
}

; Recognize a disguised andn in the following 4 tests.
define i1 @and_cmp1(i32 %x, i32 %y) {
; CHECK-LABEL: and_cmp1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl %esi, %edi, %eax
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %and = and i32 %x, %y
  %cmp = icmp eq i32 %and, %y
  ret i1 %cmp
}

define i1 @and_cmp2(i32 %x, i32 %y) {
; CHECK-LABEL: and_cmp2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl %esi, %edi, %eax
; CHECK-NEXT:    setne %al
; CHECK-NEXT:    retq
  %and = and i32 %y, %x
  %cmp = icmp ne i32 %and, %y
  ret i1 %cmp
}

define i1 @and_cmp3(i32 %x, i32 %y) {
; CHECK-LABEL: and_cmp3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl %esi, %edi, %eax
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %and = and i32 %x, %y
  %cmp = icmp eq i32 %y, %and
  ret i1 %cmp
}

define i1 @and_cmp4(i32 %x, i32 %y) {
; CHECK-LABEL: and_cmp4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnl %esi, %edi, %eax
; CHECK-NEXT:    setne %al
; CHECK-NEXT:    retq
  %and = and i32 %y, %x
  %cmp = icmp ne i32 %y, %and
  ret i1 %cmp
}

; A mask and compare against constant is ok for an 'andn' too
; even though the BMI instruction doesn't have an immediate form.
define i1 @and_cmp_const(i32 %x) {
; CHECK-LABEL: and_cmp_const:
; CHECK:       # %bb.0:
; CHECK-NEXT:    notl %edi
; CHECK-NEXT:    andl $43, %edi
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %and = and i32 %x, 43
  %cmp = icmp eq i32 %and, 43
  ret i1 %cmp
}

; But don't use 'andn' if the mask is a power-of-two.
define i1 @and_cmp_const_power_of_two(i32 %x, i32 %y) {
; CHECK-LABEL: and_cmp_const_power_of_two:
; CHECK:       # %bb.0:
; CHECK-NEXT:    btl %esi, %edi
; CHECK-NEXT:    setae %al
; CHECK-NEXT:    retq
  %shl = shl i32 1, %y
  %and = and i32 %x, %shl
  %cmp = icmp ne i32 %and, %shl
  ret i1 %cmp
}

; Don't transform to 'andn' if there's another use of the 'and'.
define i32 @and_cmp_not_one_use(i32 %x) {
; CHECK-LABEL: and_cmp_not_one_use:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andl $37, %edi
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    cmpl $37, %edi
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    addl %edi, %eax
; CHECK-NEXT:    retq
  %and = and i32 %x, 37
  %cmp = icmp eq i32 %and, 37
  %ext = zext i1 %cmp to i32
  %add = add i32 %and, %ext
  ret i32 %add
}

; Verify that we're not transforming invalid comparison predicates.
define i1 @not_an_andn1(i32 %x, i32 %y) {
; CHECK-LABEL: not_an_andn1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andl %esi, %edi
; CHECK-NEXT:    cmpl %edi, %esi
; CHECK-NEXT:    setg %al
; CHECK-NEXT:    retq
  %and = and i32 %x, %y
  %cmp = icmp sgt i32 %y, %and
  ret i1 %cmp
}

define i1 @not_an_andn2(i32 %x, i32 %y) {
; CHECK-LABEL: not_an_andn2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andl %esi, %edi
; CHECK-NEXT:    cmpl %edi, %esi
; CHECK-NEXT:    setbe %al
; CHECK-NEXT:    retq
  %and = and i32 %y, %x
  %cmp = icmp ule i32 %y, %and
  ret i1 %cmp
}

; Don't choose a 'test' if an 'andn' can be used.
define i1 @andn_cmp_swap_ops(i64 %x, i64 %y) {
; CHECK-LABEL: andn_cmp_swap_ops:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andnq %rsi, %rdi, %rax
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %notx = xor i64 %x, -1
  %and = and i64 %y, %notx
  %cmp = icmp eq i64 %and, 0
  ret i1 %cmp
}

; Use a 'test' (not an 'and') because 'andn' only works for i32/i64.
define i1 @andn_cmp_i8(i8 %x, i8 %y) {
; CHECK-LABEL: andn_cmp_i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    notb %sil
; CHECK-NEXT:    testb %sil, %dil
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %noty = xor i8 %y, -1
  %and = and i8 %x, %noty
  %cmp = icmp eq i8 %and, 0
  ret i1 %cmp
}

define i32 @bextr32(i32 %x, i32 %y)   {
; CHECK-LABEL: bextr32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    bextrl %esi, %edi, %eax
; CHECK-NEXT:    retq
  %tmp = tail call i32 @llvm.x86.bmi.bextr.32(i32 %x, i32 %y)
  ret i32 %tmp
}

define i32 @bextr32_load(i32* %x, i32 %y)   {
; CHECK-LABEL: bextr32_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    bextrl %esi, (%rdi), %eax
; CHECK-NEXT:    retq
  %x1 = load i32, i32* %x
  %tmp = tail call i32 @llvm.x86.bmi.bextr.32(i32 %x1, i32 %y)
  ret i32 %tmp
}

declare i32 @llvm.x86.bmi.bextr.32(i32, i32)

define i32 @bextr32b(i32 %x)  uwtable  ssp {
; CHECK-LABEL: bextr32b:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $3076, %eax # imm = 0xC04
; CHECK-NEXT:    bextrl %eax, %edi, %eax
; CHECK-NEXT:    retq
  %1 = lshr i32 %x, 4
  %2 = and i32 %1, 4095
  ret i32 %2
}

; Make sure we still use AH subreg trick to extract 15:8
define i32 @bextr32_subreg(i32 %x)  uwtable  ssp {
; CHECK-LABEL: bextr32_subreg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    movzbl %ah, %eax
; CHECK-NEXT:    retq
  %1 = lshr i32 %x, 8
  %2 = and i32 %1, 255
  ret i32 %2
}

define i32 @bextr32b_load(i32* %x)  uwtable  ssp {
; CHECK-LABEL: bextr32b_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $3076, %eax # imm = 0xC04
; CHECK-NEXT:    bextrl %eax, (%rdi), %eax
; CHECK-NEXT:    retq
  %1 = load i32, i32* %x
  %2 = lshr i32 %1, 4
  %3 = and i32 %2, 4095
  ret i32 %3
}

; PR34042
define i32 @bextr32c(i32 %x, i16 zeroext %y) {
; CHECK-LABEL: bextr32c:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movswl %si, %eax
; CHECK-NEXT:    bextrl %eax, %edi, %eax
; CHECK-NEXT:    retq
  %tmp0 = sext i16 %y to i32
  %tmp1 = tail call i32 @llvm.x86.bmi.bextr.32(i32 %x, i32 %tmp0)
  ret i32 %tmp1
}

define i64 @bextr64(i64 %x, i64 %y)   {
; CHECK-LABEL: bextr64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    bextrq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.x86.bmi.bextr.64(i64 %x, i64 %y)
  ret i64 %tmp
}

declare i64 @llvm.x86.bmi.bextr.64(i64, i64)

define i64 @bextr64b(i64 %x)  uwtable  ssp {
; CHECK-LABEL: bextr64b:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $3076, %eax # imm = 0xC04
; CHECK-NEXT:    bextrl %eax, %edi, %eax
; CHECK-NEXT:    retq
  %1 = lshr i64 %x, 4
  %2 = and i64 %1, 4095
  ret i64 %2
}

; Make sure we still use the AH subreg trick to extract 15:8
define i64 @bextr64_subreg(i64 %x)  uwtable  ssp {
; CHECK-LABEL: bextr64_subreg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    movzbl %ah, %eax
; CHECK-NEXT:    retq
  %1 = lshr i64 %x, 8
  %2 = and i64 %1, 255
  ret i64 %2
}

define i64 @bextr64b_load(i64* %x) {
; CHECK-LABEL: bextr64b_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $3076, %eax # imm = 0xC04
; CHECK-NEXT:    bextrl %eax, (%rdi), %eax
; CHECK-NEXT:    retq
  %1 = load i64, i64* %x, align 8
  %2 = lshr i64 %1, 4
  %3 = and i64 %2, 4095
  ret i64 %3
}

; PR34042
define i64 @bextr64c(i64 %x, i32 %y) {
; CHECK-LABEL: bextr64c:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movslq %esi, %rax
; CHECK-NEXT:    bextrq %rax, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp0 = sext i32 %y to i64
  %tmp1 = tail call i64 @llvm.x86.bmi.bextr.64(i64 %x, i64 %tmp0)
  ret i64 %tmp1
}

define i64 @bextr64d(i64 %a) {
; CHECK-LABEL: bextr64d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl $8450, %eax # imm = 0x2102
; CHECK-NEXT:    bextrq %rax, %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %shr = lshr i64 %a, 2
  %and = and i64 %shr, 8589934591
  ret i64 %and
}

define i32 @non_bextr32(i32 %x) {
; CHECK-LABEL: non_bextr32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    shrl $2, %edi
; CHECK-NEXT:    andl $111, %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
entry:
  %shr = lshr i32 %x, 2
  %and = and i32 %shr, 111
  ret i32 %and
}

define i64 @non_bextr64(i64 %x) {
; CHECK-LABEL: non_bextr64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    shrq $2, %rdi
; CHECK-NEXT:    movabsq $8589934590, %rax # imm = 0x1FFFFFFFE
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %shr = lshr i64 %x, 2
  %and = and i64 %shr, 8589934590
  ret i64 %and
}

define i32 @bzhi32b(i32 %x, i8 zeroext %index) {
; BMI1-LABEL: bzhi32b:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $1, %eax
; BMI1-NEXT:    movl %esi, %ecx
; BMI1-NEXT:    shll %cl, %eax
; BMI1-NEXT:    decl %eax
; BMI1-NEXT:    andl %edi, %eax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi32b:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhil %esi, %edi, %eax
; BMI2-NEXT:    retq
entry:
  %conv = zext i8 %index to i32
  %shl = shl i32 1, %conv
  %sub = add nsw i32 %shl, -1
  %and = and i32 %sub, %x
  ret i32 %and
}

define i32 @bzhi32b_load(i32* %w, i8 zeroext %index) {
; BMI1-LABEL: bzhi32b_load:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $1, %eax
; BMI1-NEXT:    movl %esi, %ecx
; BMI1-NEXT:    shll %cl, %eax
; BMI1-NEXT:    decl %eax
; BMI1-NEXT:    andl (%rdi), %eax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi32b_load:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhil %esi, (%rdi), %eax
; BMI2-NEXT:    retq
entry:
  %x = load i32, i32* %w
  %conv = zext i8 %index to i32
  %shl = shl i32 1, %conv
  %sub = add nsw i32 %shl, -1
  %and = and i32 %sub, %x
  ret i32 %and
}

define i32 @bzhi32c(i32 %x, i8 zeroext %index) {
; BMI1-LABEL: bzhi32c:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $1, %eax
; BMI1-NEXT:    movl %esi, %ecx
; BMI1-NEXT:    shll %cl, %eax
; BMI1-NEXT:    decl %eax
; BMI1-NEXT:    andl %edi, %eax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi32c:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhil %esi, %edi, %eax
; BMI2-NEXT:    retq
entry:
  %conv = zext i8 %index to i32
  %shl = shl i32 1, %conv
  %sub = add nsw i32 %shl, -1
  %and = and i32 %x, %sub
  ret i32 %and
}

define i32 @bzhi32d(i32 %a, i32 %b) {
; BMI1-LABEL: bzhi32d:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $32, %ecx
; BMI1-NEXT:    subl %esi, %ecx
; BMI1-NEXT:    movl $-1, %eax
; BMI1-NEXT:    # kill: def $cl killed $cl killed $ecx
; BMI1-NEXT:    shrl %cl, %eax
; BMI1-NEXT:    andl %edi, %eax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi32d:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhil %esi, %edi, %eax
; BMI2-NEXT:    retq
entry:
  %sub = sub i32 32, %b
  %shr = lshr i32 -1, %sub
  %and = and i32 %shr, %a
  ret i32 %and
}

define i32 @bzhi32e(i32 %a, i32 %b) {
; BMI1-LABEL: bzhi32e:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $32, %ecx
; BMI1-NEXT:    subl %esi, %ecx
; BMI1-NEXT:    shll %cl, %edi
; BMI1-NEXT:    # kill: def $cl killed $cl killed $ecx
; BMI1-NEXT:    shrl %cl, %edi
; BMI1-NEXT:    movl %edi, %eax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi32e:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhil %esi, %edi, %eax
; BMI2-NEXT:    retq
entry:
  %sub = sub i32 32, %b
  %shl = shl i32 %a, %sub
  %shr = lshr i32 %shl, %sub
  ret i32 %shr
}

define i64 @bzhi64b(i64 %x, i8 zeroext %index) {
; BMI1-LABEL: bzhi64b:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $1, %eax
; BMI1-NEXT:    movl %esi, %ecx
; BMI1-NEXT:    shlq %cl, %rax
; BMI1-NEXT:    decq %rax
; BMI1-NEXT:    andq %rdi, %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64b:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    # kill: def $esi killed $esi def $rsi
; BMI2-NEXT:    bzhiq %rsi, %rdi, %rax
; BMI2-NEXT:    retq
entry:
  %conv = zext i8 %index to i64
  %shl = shl i64 1, %conv
  %sub = add nsw i64 %shl, -1
  %and = and i64 %x, %sub
  ret i64 %and
}

define i64 @bzhi64c(i64 %a, i64 %b) {
; BMI1-LABEL: bzhi64c:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $64, %ecx
; BMI1-NEXT:    subl %esi, %ecx
; BMI1-NEXT:    movq $-1, %rax
; BMI1-NEXT:    # kill: def $cl killed $cl killed $ecx
; BMI1-NEXT:    shrq %cl, %rax
; BMI1-NEXT:    andq %rdi, %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64c:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhiq %rsi, %rdi, %rax
; BMI2-NEXT:    retq
entry:
  %sub = sub i64 64, %b
  %shr = lshr i64 -1, %sub
  %and = and i64 %shr, %a
  ret i64 %and
}

define i64 @bzhi64d(i64 %a, i32 %b) {
; BMI1-LABEL: bzhi64d:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $64, %ecx
; BMI1-NEXT:    subl %esi, %ecx
; BMI1-NEXT:    movq $-1, %rax
; BMI1-NEXT:    # kill: def $cl killed $cl killed $ecx
; BMI1-NEXT:    shrq %cl, %rax
; BMI1-NEXT:    andq %rdi, %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64d:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    # kill: def $esi killed $esi def $rsi
; BMI2-NEXT:    bzhiq %rsi, %rdi, %rax
; BMI2-NEXT:    retq
entry:
  %sub = sub i32 64, %b
  %sh_prom = zext i32 %sub to i64
  %shr = lshr i64 -1, %sh_prom
  %and = and i64 %shr, %a
  ret i64 %and
}

define i64 @bzhi64e(i64 %a, i64 %b) {
; BMI1-LABEL: bzhi64e:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $64, %ecx
; BMI1-NEXT:    subl %esi, %ecx
; BMI1-NEXT:    shlq %cl, %rdi
; BMI1-NEXT:    # kill: def $cl killed $cl killed $ecx
; BMI1-NEXT:    shrq %cl, %rdi
; BMI1-NEXT:    movq %rdi, %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64e:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    bzhiq %rsi, %rdi, %rax
; BMI2-NEXT:    retq
entry:
  %sub = sub i64 64, %b
  %shl = shl i64 %a, %sub
  %shr = lshr i64 %shl, %sub
  ret i64 %shr
}

define i64 @bzhi64f(i64 %a, i32 %b) {
; BMI1-LABEL: bzhi64f:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $64, %ecx
; BMI1-NEXT:    subl %esi, %ecx
; BMI1-NEXT:    shlq %cl, %rdi
; BMI1-NEXT:    # kill: def $cl killed $cl killed $ecx
; BMI1-NEXT:    shrq %cl, %rdi
; BMI1-NEXT:    movq %rdi, %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64f:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    # kill: def $esi killed $esi def $rsi
; BMI2-NEXT:    bzhiq %rsi, %rdi, %rax
; BMI2-NEXT:    retq
entry:
  %sub = sub i32 64, %b
  %sh_prom = zext i32 %sub to i64
  %shl = shl i64 %a, %sh_prom
  %shr = lshr i64 %shl, %sh_prom
  ret i64 %shr
}

define i64 @bzhi64_constant_mask(i64 %x) {
; BMI1-LABEL: bzhi64_constant_mask:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $15872, %eax # imm = 0x3E00
; BMI1-NEXT:    bextrq %rax, %rdi, %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64_constant_mask:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    movb $62, %al
; BMI2-NEXT:    bzhiq %rax, %rdi, %rax
; BMI2-NEXT:    retq
entry:
  %and = and i64 %x, 4611686018427387903
  ret i64 %and
}

define i64 @bzhi64_constant_mask_load(i64* %x) {
; BMI1-LABEL: bzhi64_constant_mask_load:
; BMI1:       # %bb.0: # %entry
; BMI1-NEXT:    movl $15872, %eax # imm = 0x3E00
; BMI1-NEXT:    bextrq %rax, (%rdi), %rax
; BMI1-NEXT:    retq
;
; BMI2-LABEL: bzhi64_constant_mask_load:
; BMI2:       # %bb.0: # %entry
; BMI2-NEXT:    movb $62, %al
; BMI2-NEXT:    bzhiq %rax, (%rdi), %rax
; BMI2-NEXT:    retq
entry:
  %x1 = load i64, i64* %x
  %and = and i64 %x1, 4611686018427387903
  ret i64 %and
}

define i64 @bzhi64_small_constant_mask(i64 %x) {
; CHECK-LABEL: bzhi64_small_constant_mask:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andl $2147483647, %edi # imm = 0x7FFFFFFF
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %and = and i64 %x, 2147483647
  ret i64 %and
}

define i32 @blsi32(i32 %x)   {
; CHECK-LABEL: blsi32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsil %edi, %eax
; CHECK-NEXT:    retq
  %tmp = sub i32 0, %x
  %tmp2 = and i32 %x, %tmp
  ret i32 %tmp2
}

define i32 @blsi32_load(i32* %x)   {
; CHECK-LABEL: blsi32_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsil (%rdi), %eax
; CHECK-NEXT:    retq
  %x1 = load i32, i32* %x
  %tmp = sub i32 0, %x1
  %tmp2 = and i32 %x1, %tmp
  ret i32 %tmp2
}

define i64 @blsi64(i64 %x)   {
; CHECK-LABEL: blsi64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsiq %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = sub i64 0, %x
  %tmp2 = and i64 %tmp, %x
  ret i64 %tmp2
}

define i32 @blsmsk32(i32 %x)   {
; CHECK-LABEL: blsmsk32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsmskl %edi, %eax
; CHECK-NEXT:    retq
  %tmp = sub i32 %x, 1
  %tmp2 = xor i32 %x, %tmp
  ret i32 %tmp2
}

define i32 @blsmsk32_load(i32* %x)   {
; CHECK-LABEL: blsmsk32_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsmskl (%rdi), %eax
; CHECK-NEXT:    retq
  %x1 = load i32, i32* %x
  %tmp = sub i32 %x1, 1
  %tmp2 = xor i32 %x1, %tmp
  ret i32 %tmp2
}

define i64 @blsmsk64(i64 %x)   {
; CHECK-LABEL: blsmsk64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsmskq %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = sub i64 %x, 1
  %tmp2 = xor i64 %tmp, %x
  ret i64 %tmp2
}

define i32 @blsr32(i32 %x)   {
; CHECK-LABEL: blsr32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsrl %edi, %eax
; CHECK-NEXT:    retq
  %tmp = sub i32 %x, 1
  %tmp2 = and i32 %x, %tmp
  ret i32 %tmp2
}

define i32 @blsr32_load(i32* %x)   {
; CHECK-LABEL: blsr32_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsrl (%rdi), %eax
; CHECK-NEXT:    retq
  %x1 = load i32, i32* %x
  %tmp = sub i32 %x1, 1
  %tmp2 = and i32 %x1, %tmp
  ret i32 %tmp2
}

define i64 @blsr64(i64 %x)   {
; CHECK-LABEL: blsr64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsrq %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = sub i64 %x, 1
  %tmp2 = and i64 %tmp, %x
  ret i64 %tmp2
}

; PR35792 - https://bugs.llvm.org/show_bug.cgi?id=35792

define i64 @blsr_disguised_constant(i64 %x) {
; CHECK-LABEL: blsr_disguised_constant:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blsrl %edi, %eax
; CHECK-NEXT:    movzwl %ax, %eax
; CHECK-NEXT:    retq
  %a1 = and i64 %x, 65535
  %a2 = add i64 %x, 65535
  %r = and i64 %a1, %a2
  ret i64 %r
}

; The add here gets shrunk, but the and does not thus hiding the blsr pattern.
define i64 @blsr_disguised_shrunk_add(i64 %x) {
; CHECK-LABEL: blsr_disguised_shrunk_add:
; CHECK:       # %bb.0:
; CHECK-NEXT:    shrq $48, %rdi
; CHECK-NEXT:    leal -1(%rdi), %eax
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
  %a = lshr i64 %x, 48
  %b = add i64 %a, -1
  %c = and i64 %b, %a
  ret i64 %c
}
