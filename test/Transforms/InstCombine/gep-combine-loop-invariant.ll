; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @foo(i8* nocapture readnone %match, i32 %cur_match, i32 %best_len, i32 %scan_end, i32* nocapture readonly %prev, i32 %limit, i32 %chain_length, i8* nocapture readonly %win, i32 %wmask) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[IDX_EXT2:%.*]] = zext i32 [[CUR_MATCH:%.*]] to i64
; CHECK-NEXT:    [[ADD_PTR4:%.*]] = getelementptr inbounds i8, i8* [[WIN:%.*]], i64 [[IDX_EXT2]]
; CHECK-NEXT:    [[IDX_EXT1:%.*]] = zext i32 [[BEST_LEN:%.*]] to i64
; CHECK-NEXT:    [[ADD_PTR25:%.*]] = getelementptr inbounds i8, i8* [[ADD_PTR4]], i64 [[IDX_EXT1]]
; CHECK-NEXT:    [[ADD_PTR36:%.*]] = getelementptr inbounds i8, i8* [[ADD_PTR25]], i64 -1
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i8* [[ADD_PTR36]] to i32*
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[TMP0]], align 4
; CHECK-NEXT:    [[CMP7:%.*]] = icmp eq i32 [[TMP1]], [[SCAN_END:%.*]]
; CHECK-NEXT:    br i1 [[CMP7]], label [[DO_END:%.*]], label [[IF_THEN_LR_PH:%.*]]
; CHECK:       if.then.lr.ph:
; CHECK-NEXT:    br label [[IF_THEN:%.*]]
; CHECK:       do.body:
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[TMP4:%.*]] to i64
; CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i8, i8* [[WIN]], i64 [[IDX_EXT1]]
; CHECK-NEXT:    [[ADD_PTR2:%.*]] = getelementptr inbounds i8, i8* [[ADD_PTR]], i64 -1
; CHECK-NEXT:    [[ADD_PTR3:%.*]] = getelementptr inbounds i8, i8* [[ADD_PTR2]], i64 [[IDX_EXT]]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[ADD_PTR3]] to i32*
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[TMP3]], [[SCAN_END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[DO_END]], label [[IF_THEN]]
; CHECK:       if.then:
; CHECK-NEXT:    [[CUR_MATCH_ADDR_09:%.*]] = phi i32 [ [[CUR_MATCH]], [[IF_THEN_LR_PH]] ], [ [[TMP4]], [[DO_BODY:%.*]] ]
; CHECK-NEXT:    [[CHAIN_LENGTH_ADDR_08:%.*]] = phi i32 [ [[CHAIN_LENGTH:%.*]], [[IF_THEN_LR_PH]] ], [ [[DEC:%.*]], [[DO_BODY]] ]
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[CUR_MATCH_ADDR_09]], [[WMASK:%.*]]
; CHECK-NEXT:    [[IDXPROM:%.*]] = zext i32 [[AND]] to i64
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[PREV:%.*]], i64 [[IDXPROM]]
; CHECK-NEXT:    [[TMP4]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[CMP4:%.*]] = icmp ugt i32 [[TMP4]], [[LIMIT:%.*]]
; CHECK-NEXT:    br i1 [[CMP4]], label [[LAND_LHS_TRUE:%.*]], label [[DO_END]]
; CHECK:       land.lhs.true:
; CHECK-NEXT:    [[DEC]] = add i32 [[CHAIN_LENGTH_ADDR_08]], -1
; CHECK-NEXT:    [[CMP5:%.*]] = icmp eq i32 [[DEC]], 0
; CHECK-NEXT:    br i1 [[CMP5]], label [[DO_END]], label [[DO_BODY]]
; CHECK:       do.end:
; CHECK-NEXT:    [[CONT_0:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ 0, [[IF_THEN]] ], [ 0, [[LAND_LHS_TRUE]] ], [ 1, [[DO_BODY]] ]
; CHECK-NEXT:    ret i32 [[CONT_0]]
;
entry:
  %idx.ext2 = zext i32 %cur_match to i64
  %add.ptr4 = getelementptr inbounds i8, i8* %win, i64 %idx.ext2
  %idx.ext1 = zext i32 %best_len to i64
  %add.ptr25 = getelementptr inbounds i8, i8* %add.ptr4, i64 %idx.ext1
  %add.ptr36 = getelementptr inbounds i8, i8* %add.ptr25, i64 -1
  %0 = bitcast i8* %add.ptr36 to i32*
  %1 = load i32, i32* %0, align 4
  %cmp7 = icmp eq i32 %1, %scan_end
  br i1 %cmp7, label %do.end, label %if.then.lr.ph

if.then.lr.ph:                                    ; preds = %entry
  br label %if.then

do.body:                                          ; preds = %land.lhs.true
  %chain_length.addr.0 = phi i32 [ %dec, %land.lhs.true ]
  %cur_match.addr.0 = phi i32 [ %4, %land.lhs.true ]
  %idx.ext = zext i32 %cur_match.addr.0 to i64
  %add.ptr = getelementptr inbounds i8, i8* %win, i64 %idx.ext
  %add.ptr2 = getelementptr inbounds i8, i8* %add.ptr, i64 %idx.ext1
  %add.ptr3 = getelementptr inbounds i8, i8* %add.ptr2, i64 -1
  %2 = bitcast i8* %add.ptr3 to i32*
  %3 = load i32, i32* %2, align 4
  %cmp = icmp eq i32 %3, %scan_end
  br i1 %cmp, label %do.end, label %if.then

if.then:                                          ; preds = %if.then.lr.ph, %do.body
  %cur_match.addr.09 = phi i32 [ %cur_match, %if.then.lr.ph ], [ %cur_match.addr.0, %do.body ]
  %chain_length.addr.08 = phi i32 [ %chain_length, %if.then.lr.ph ], [ %chain_length.addr.0, %do.body ]
  %and = and i32 %cur_match.addr.09, %wmask
  %idxprom = zext i32 %and to i64
  %arrayidx = getelementptr inbounds i32, i32* %prev, i64 %idxprom
  %4 = load i32, i32* %arrayidx, align 4
  %cmp4 = icmp ugt i32 %4, %limit
  br i1 %cmp4, label %land.lhs.true, label %do.end

land.lhs.true:                                    ; preds = %if.then
  %dec = add i32 %chain_length.addr.08, -1
  %cmp5 = icmp eq i32 %dec, 0
  br i1 %cmp5, label %do.end, label %do.body

do.end:                                           ; preds = %do.body, %land.lhs.true, %if.then, %entry
  %cont.0 = phi i32 [ 1, %entry ], [ 0, %if.then ], [ 0, %land.lhs.true ], [ 1, %do.body ]
  ret i32 %cont.0
}
