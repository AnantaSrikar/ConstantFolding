; ModuleID = 'fncomputation-m2r.ll'
source_filename = "./tests/computation.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @computeSquare(i32 noundef %x) #0 {
entry:
  %mul = mul nsw i32 %x, %x
  ret i32 %mul
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @computeTriple(i32 noundef %x) #0 {
entry:
  %mul = mul nsw i32 3, %x
  ret i32 %mul
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @compute(i32 noundef %var) #0 {
entry:
  br i1 true, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  br label %if.end

if.else:                                          ; preds = %entry
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  br i1 false, label %if.then10, label %if.else11

if.then10:                                        ; preds = %if.end
  br label %return

if.else11:                                        ; preds = %if.end
  br label %if.end12

if.end12:                                         ; preds = %if.else11
  %add13 = add nsw i32 22, %var
  %add16 = add nsw i32 %add13, 55
  br label %return

return:                                           ; preds = %if.end12, %if.then10
  %retval.0 = phi i32 [ -1, %if.then10 ], [ %add16, %if.end12 ]
  ret i32 %retval.0
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 17.0.6 (https://github.com/llvm/llvm-project.git 6009708b4367171ccdbf4b5905cb6a803753fe18)"}
