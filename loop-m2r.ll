; ModuleID = 'loop.bc'
source_filename = "./tests/loop.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [12 x i8] c"Result: %d\0A\00", align 1

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
define dso_local i32 @main() #0 {
entry:
  %call = call i32 @computeSquare(i32 noundef 10)
  %call1 = call i32 @computeTriple(i32 noundef 5)
  %mul = mul nsw i32 %call, 5
  %mul2 = mul nsw i32 %call1, 10
  %add = add nsw i32 %mul, %mul2
  %add3 = add nsw i32 %add, 50
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %complexCalculation.0 = phi i32 [ %add3, %entry ], [ %add6, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %call4 = call i32 @computeSquare(i32 noundef 5)
  %mul5 = mul nsw i32 %i.0, %call4
  %add6 = add nsw i32 %complexCalculation.0, %mul5
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond, !llvm.loop !6

for.end:                                          ; preds = %for.cond
  %call7 = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %complexCalculation.0)
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 17.0.6 (https://github.com/llvm/llvm-project.git 6009708b4367171ccdbf4b5905cb6a803753fe18)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
