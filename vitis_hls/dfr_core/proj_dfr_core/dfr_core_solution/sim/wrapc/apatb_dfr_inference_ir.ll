; ModuleID = '/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vitis_hls/dfr_core/proj_dfr_core/dfr_core_solution/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: noinline
define void @apatb_dfr_inference_ir(i32* %inputs, i32* %weights, i64* %outputs) local_unnamed_addr #0 {
entry:
  %malloccall = tail call i8* @malloc(i64 2040800)
  %inputs_copy = bitcast i8* %malloccall to [510200 x i32]*
  %weights_copy = alloca [100 x i32], align 512
  %malloccall1 = tail call i8* @malloc(i64 40656)
  %outputs_copy = bitcast i8* %malloccall1 to [5082 x i64]*
  %0 = bitcast i32* %inputs to [510200 x i32]*
  %1 = bitcast i32* %weights to [100 x i32]*
  %2 = bitcast i64* %outputs to [5082 x i64]*
  call fastcc void @copy_in([510200 x i32]* %0, [510200 x i32]* %inputs_copy, [100 x i32]* %1, [100 x i32]* nonnull align 512 %weights_copy, [5082 x i64]* %2, [5082 x i64]* %outputs_copy)
  %3 = getelementptr inbounds [510200 x i32], [510200 x i32]* %inputs_copy, i32 0, i32 0
  %4 = getelementptr inbounds [100 x i32], [100 x i32]* %weights_copy, i32 0, i32 0
  %5 = getelementptr inbounds [5082 x i64], [5082 x i64]* %outputs_copy, i32 0, i32 0
  call void @apatb_dfr_inference_hw(i32* %3, i32* %4, i64* %5)
  call fastcc void @copy_out([510200 x i32]* %0, [510200 x i32]* %inputs_copy, [100 x i32]* %1, [100 x i32]* nonnull align 512 %weights_copy, [5082 x i64]* %2, [5082 x i64]* %outputs_copy)
  tail call void @free(i8* %malloccall)
  tail call void @free(i8* %malloccall1)
  ret void
}

declare noalias i8* @malloc(i64) local_unnamed_addr

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_in([510200 x i32]* readonly, [510200 x i32]* noalias, [100 x i32]* readonly, [100 x i32]* noalias align 512, [5082 x i64]* readonly, [5082 x i64]* noalias) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0a510200i32([510200 x i32]* %1, [510200 x i32]* %0)
  call fastcc void @onebyonecpy_hls.p0a100i32([100 x i32]* align 512 %3, [100 x i32]* %2)
  call fastcc void @onebyonecpy_hls.p0a5082i64([5082 x i64]* %5, [5082 x i64]* %4)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @onebyonecpy_hls.p0a510200i32([510200 x i32]* noalias, [510200 x i32]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [510200 x i32]* %0, null
  %3 = icmp eq [510200 x i32]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx3 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr.gep1 = getelementptr [510200 x i32], [510200 x i32]* %0, i64 0, i64 %for.loop.idx3
  %5 = bitcast i32* %dst.addr.gep1 to i8*
  %src.addr.gep2 = getelementptr [510200 x i32], [510200 x i32]* %1, i64 0, i64 %for.loop.idx3
  %6 = bitcast i32* %src.addr.gep2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %5, i8* align 1 %6, i64 4, i1 false)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx3, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 510200
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #3

; Function Attrs: argmemonly noinline
define internal fastcc void @onebyonecpy_hls.p0a100i32([100 x i32]* noalias align 512, [100 x i32]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [100 x i32]* %0, null
  %3 = icmp eq [100 x i32]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx3 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr.gep1 = getelementptr [100 x i32], [100 x i32]* %0, i64 0, i64 %for.loop.idx3
  %5 = bitcast i32* %dst.addr.gep1 to i8*
  %src.addr.gep2 = getelementptr [100 x i32], [100 x i32]* %1, i64 0, i64 %for.loop.idx3
  %6 = bitcast i32* %src.addr.gep2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %5, i8* align 1 %6, i64 4, i1 false)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx3, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 100
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @onebyonecpy_hls.p0a5082i64([5082 x i64]* noalias, [5082 x i64]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [5082 x i64]* %0, null
  %3 = icmp eq [5082 x i64]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx3 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr.gep1 = getelementptr [5082 x i64], [5082 x i64]* %0, i64 0, i64 %for.loop.idx3
  %5 = bitcast i64* %dst.addr.gep1 to i8*
  %src.addr.gep2 = getelementptr [5082 x i64], [5082 x i64]* %1, i64 0, i64 %for.loop.idx3
  %6 = bitcast i64* %src.addr.gep2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %5, i8* align 1 %6, i64 8, i1 false)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx3, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 5082
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_out([510200 x i32]*, [510200 x i32]* noalias readonly, [100 x i32]*, [100 x i32]* noalias readonly align 512, [5082 x i64]*, [5082 x i64]* noalias readonly) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a510200i32([510200 x i32]* %0, [510200 x i32]* %1)
  call fastcc void @onebyonecpy_hls.p0a100i32([100 x i32]* %2, [100 x i32]* align 512 %3)
  call fastcc void @onebyonecpy_hls.p0a5082i64([5082 x i64]* %4, [5082 x i64]* %5)
  ret void
}

declare void @free(i8*) local_unnamed_addr

declare void @apatb_dfr_inference_hw(i32*, i32*, i64*)

define void @dfr_inference_hw_stub_wrapper(i32*, i32*, i64*) #5 {
entry:
  %3 = bitcast i32* %0 to [510200 x i32]*
  %4 = bitcast i32* %1 to [100 x i32]*
  %5 = bitcast i64* %2 to [5082 x i64]*
  call void @copy_out([510200 x i32]* null, [510200 x i32]* %3, [100 x i32]* null, [100 x i32]* %4, [5082 x i64]* null, [5082 x i64]* %5)
  %6 = bitcast [510200 x i32]* %3 to i32*
  %7 = bitcast [100 x i32]* %4 to i32*
  %8 = bitcast [5082 x i64]* %5 to i64*
  call void @dfr_inference_hw_stub(i32* %6, i32* %7, i64* %8)
  call void @copy_in([510200 x i32]* null, [510200 x i32]* %3, [100 x i32]* null, [100 x i32]* %4, [5082 x i64]* null, [5082 x i64]* %5)
  ret void
}

declare void @dfr_inference_hw_stub(i32*, i32*, i64*)

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly nounwind }
attributes #4 = { argmemonly noinline "fpga.wrapper.func"="copyout" }
attributes #5 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
