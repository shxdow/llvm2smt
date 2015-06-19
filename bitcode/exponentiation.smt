(set-logic QF_ABV)
(define-sort Address () (_ BitVec 64))
(define-sort Byte () (_ BitVec 8))
(define-sort Mem () (Array Address Byte))

(define-sort I8 () (_ BitVec 8))
(define-sort I16 () (_ BitVec 16))
(define-sort I32 () (_ BitVec 32))
(define-sort I64 () (_ BitVec 64))
(define-sort I128 () (_ BitVec 128))


;;
;;constants
;;
(define-fun zero  () Address (_ bv0 64))
(define-fun one   () Address (_ bv1 64))
(define-fun two   () Address (_ bv2 64))
(define-fun three () Address (_ bv3 64))
(define-fun four  () Address (_ bv4 64))
(define-fun five  () Address (_ bv5 64))
(define-fun six   () Address (_ bv6 64))
(define-fun seven () Address (_ bv7 64))
(define-fun eight () Address (_ bv8 64))


;;
;; Write a little endian 1 bit value (8 bit aligned) at address x in mem
;;
(define-fun write1 ((mem Mem) (x Address) (v Bool)) Mem
  (store mem x (ite v #x01 #x00)))

;;
;; Write a little endian 8bit value at address x in mem
;;
(define-fun write8 ((mem Mem) (x Address) (v I8)) Mem
  (store mem x v))

;;
;; Write a little endian 16bit value at address x in mem
;;
(define-fun write16 ((mem Mem) (x Address) (v I16)) Mem
  (let ((b0 ((_ extract 7 0) v))
	(b1 ((_ extract 15 8) v)))
    (store (store mem x b0) (bvadd x one) b1)))

;;
;; Write a little endian 32bit value at address x in mem
;;
(define-fun write32 ((mem Mem) (x Address) (v I32)) Mem
  (let ((b0 ((_ extract 7 0) v))
	(b1 ((_ extract 15 8) v))
	(b2 ((_ extract 23 16) v))
	(b3 ((_ extract 31 24) v)))
    (store (store (store (store mem x b0) (bvadd x one) b1) (bvadd x two) b2) (bvadd x three) b3)))

;;
;; Write a little endian 64bit value at address x in mem
;;
(define-fun write64 ((mem Mem) (x Address) (v I64)) Mem
  (let ((b0 ((_ extract 31 0) v))
	(b1 ((_ extract 63 32) v)))
    (write32 (write32 mem x b0) (bvadd x four) b1)))

;;
;; Write a little endian 128bit value at address x in mem
;;
(define-fun write128 ((mem Mem) (x Address) (v I128)) Mem
  (let ((b0 ((_ extract 63 0) v))
	(b1 ((_ extract 127 64) v)))
    (write64 (write64 mem x b0) (bvadd x eight) b1)))


;;
;; Read a little endian 1 bit value (8 bit aligned) at address x in mem
;; - returns a Boolean: true if what's stored at address x is non-zero
;;
(define-fun read1 ((mem Mem) (x Address)) Bool
   (not (= (select mem x) #x00)))

;;
;; Read a little endian 8bit value at address x in mem
;;
(define-fun read8 ((mem Mem) (x Address)) I8
  (select mem x))

;;
;; Read a little endian 16bit value at address x in mem
;;
(define-fun read16 ((mem Mem) (x Address)) I16
  (let ((b0 (select mem x))
	(b1 (select mem (bvadd x one))))
    (concat b1 b0))) 

;;
;; Read a little endian 32bit value at address x in mem
;;
(define-fun read32 ((mem Mem) (x Address)) I32
  (let ((b0 (select mem x))
	(b1 (select mem (bvadd x one)))
	(b2 (select mem (bvadd x two)))
	(b3 (select mem (bvadd x three))))
    (concat b3 (concat b2 (concat b1 b0)))))

;;
;; Read a little endian 64bit value at address x in mem
;;
(define-fun read64 ((mem Mem) (x Address)) I64
  (let ((b0 (read32 mem x))
        (b1 (read32 mem (bvadd x four))))
    (concat b1 b0)))

;;
;; Read a little endian 128bit value at address x in mem
;;
(define-fun read128 ((mem Mem) (x Address)) I128
  (let ((b0 (read64 mem x))
        (b1 (read64 mem (bvadd x eight))))
    (concat b1 b0)))



;; Function: |@exp0|
;; (i32 %a, i32 %b)
(declare-fun memory1 () Mem)
(define-fun rsp1 () (_ BitVec 64) (_ bv0 64))
(declare-fun |%a_@exp0| () (_ BitVec 32))
(declare-fun |%b_@exp0| () (_ BitVec 32))

;; BLOCK %0 with index 0 and rank = 1
;; Predecessors:
;; @exp0_block_0_entry_condition 
(define-fun @exp0_block_0_entry_condition () Bool true)
;; %1 = alloca i32, align 4
(define-fun rsp2 () Address (bvsub rsp1 (_ bv4 64)))
(define-fun |%1_@exp0| () (_ BitVec 64) rsp2)
;; %2 = alloca i32, align 4
(define-fun rsp3 () Address (bvsub rsp2 (_ bv4 64)))
(define-fun |%2_@exp0| () (_ BitVec 64) rsp3)
;; %3 = alloca i32, align 4
(define-fun rsp4 () Address (bvsub rsp3 (_ bv4 64)))
(define-fun |%3_@exp0| () (_ BitVec 64) rsp4)
;; %retval = alloca i32, align 4
(define-fun rsp5 () Address (bvsub rsp4 (_ bv4 64)))
(define-fun |%retval_@exp0| () (_ BitVec 64) rsp5)
;; store i32 %a, i32* %2, align 4
(define-fun memory2 () Mem (write32 memory1 |%2_@exp0| |%a_@exp0|))
;; store i32 %b, i32* %3, align 4
(define-fun memory3 () Mem (write32 memory2 |%3_@exp0| |%b_@exp0|))
;; store i32 1, i32* %retval, align 4
(define-fun memory4 () Mem (write32 memory3 |%retval_@exp0| (_ bv1 32)))
;; %4 = load i32* %3, align 4
(define-fun |%4_@exp0| () (_ BitVec 32) (read32 memory4 |%3_@exp0|))
;; %5 = icmp slt i32 %4, 0
(define-fun |%5_@exp0| () Bool (bvslt |%4_@exp0| (_ bv0 32)))
;; br i1 %5, label %6, label %7
;; No backward arrows

;; BLOCK %6 with index 1 and rank = 2
;; Predecessors: %0
;; @exp0_block_1_entry_condition 
(define-fun @exp0_block_1_entry_condition () Bool
    (and @exp0_block_0_entry_condition |%5_@exp0|)
)
;;Memory PHI
(define-fun memory5 () Mem memory4)
;; store i32 0, i32* %1
(define-fun memory6 () Mem (write32 memory5 |%1_@exp0| (_ bv0 32)))
;; br label %19
;; No backward arrows

;; BLOCK %7 with index 2 and rank = 2
;; Predecessors: %0
;; @exp0_block_2_entry_condition 
(define-fun @exp0_block_2_entry_condition () Bool
    (and @exp0_block_0_entry_condition (not |%5_@exp0|))
)
;;Memory PHI
(define-fun memory7 () Mem memory4)
;; br label %8
;; No backward arrows

;; BLOCK %8 with index 3 and rank = 3
;; Predecessors: %11 %7
;; Backward pointers: %11
;; @exp0_block_3_entry_condition 
(define-fun @exp0_block_3_entry_condition () Bool
    @exp0_block_2_entry_condition
)
;;Memory PHI
(define-fun memory8 () Mem memory7)
;; %9 = load i32* %3, align 4
(define-fun |%9_@exp0| () (_ BitVec 32) (read32 memory8 |%3_@exp0|))
;; %10 = icmp sgt i32 %9, 0
(define-fun |%10_@exp0| () Bool (bvsgt |%9_@exp0| (_ bv0 32)))
;; br i1 %10, label %11, label %17
;; No backward arrows

;; BLOCK %11 with index 4 and rank = 4
;; Predecessors: %8
;; @exp0_block_4_entry_condition 
(define-fun @exp0_block_4_entry_condition () Bool
    (and @exp0_block_3_entry_condition |%10_@exp0|)
)
;;Memory PHI
(define-fun memory9 () Mem memory8)
;; %12 = load i32* %2, align 4
(define-fun |%12_@exp0| () (_ BitVec 32) (read32 memory9 |%2_@exp0|))
;; %13 = load i32* %retval, align 4
(define-fun |%13_@exp0| () (_ BitVec 32) (read32 memory9 |%retval_@exp0|))
;; %14 = mul nsw i32 %13, %12
(define-fun |%14_@exp0| () (_ BitVec 32) (bvmul |%13_@exp0| |%12_@exp0|))
;; store i32 %14, i32* %retval, align 4
(define-fun memory10 () Mem (write32 memory9 |%retval_@exp0| |%14_@exp0|))
;; %15 = load i32* %3, align 4
(define-fun |%15_@exp0| () (_ BitVec 32) (read32 memory10 |%3_@exp0|))
;; %16 = sub nsw i32 %15, 1
(define-fun |%16_@exp0| () (_ BitVec 32) (bvsub |%15_@exp0| (_ bv1 32)))
;; store i32 %16, i32* %3, align 4
(define-fun memory11 () Mem (write32 memory10 |%3_@exp0| |%16_@exp0|))
;; br label %8
;; BACKWARD ARROWS:  %8
(assert 
    (not @exp0_block_4_entry_condition)
)

;; BLOCK %17 with index 5 and rank = 4
;; Predecessors: %8
;; @exp0_block_5_entry_condition 
(define-fun @exp0_block_5_entry_condition () Bool
    (and @exp0_block_3_entry_condition (not |%10_@exp0|))
)
;;Memory PHI
(define-fun memory12 () Mem memory8)
;; %18 = load i32* %retval, align 4
(define-fun |%18_@exp0| () (_ BitVec 32) (read32 memory12 |%retval_@exp0|))
;; store i32 %18, i32* %1
(define-fun memory13 () Mem (write32 memory12 |%1_@exp0| |%18_@exp0|))
;; br label %19
;; No backward arrows

;; BLOCK %19 with index 6 and rank = 5
;; Predecessors: %17 %6
;; @exp0_block_6_entry_condition 
(define-fun @exp0_block_6_entry_condition () Bool
    (or
        @exp0_block_5_entry_condition
        @exp0_block_1_entry_condition
    )
)
;;Memory PHI
(define-fun memory14 () Mem 
    (ite @exp0_block_5_entry_condition memory13 memory6
    ))
;; %20 = load i32* %1
(define-fun |%20_@exp0| () (_ BitVec 32) (read32 memory14 |%1_@exp0|))
;; ret i32 %20
;; No backward arrows


(define-fun @exp0_result () (_ BitVec 32) |%20_@exp0|)

;; Function: |@exp1|
;; (i32 %a, i32 %b)
(declare-fun memory15 () Mem)
(define-fun rsp6 () (_ BitVec 64) (_ bv0 64))
(declare-fun |%a_@exp1| () (_ BitVec 32))
(declare-fun |%b_@exp1| () (_ BitVec 32))

;; BLOCK %0 with index 0 and rank = 1
;; Predecessors:
;; @exp1_block_0_entry_condition 
(define-fun @exp1_block_0_entry_condition () Bool true)
;; %1 = alloca i32, align 4
(define-fun rsp7 () Address (bvsub rsp6 (_ bv4 64)))
(define-fun |%1_@exp1| () (_ BitVec 64) rsp7)
;; %2 = alloca i32, align 4
(define-fun rsp8 () Address (bvsub rsp7 (_ bv4 64)))
(define-fun |%2_@exp1| () (_ BitVec 64) rsp8)
;; %3 = alloca i32, align 4
(define-fun rsp9 () Address (bvsub rsp8 (_ bv4 64)))
(define-fun |%3_@exp1| () (_ BitVec 64) rsp9)
;; %retval = alloca i32, align 4
(define-fun rsp10 () Address (bvsub rsp9 (_ bv4 64)))
(define-fun |%retval_@exp1| () (_ BitVec 64) rsp10)
;; store i32 %a, i32* %2, align 4
(define-fun memory16 () Mem (write32 memory15 |%2_@exp1| |%a_@exp1|))
;; store i32 %b, i32* %3, align 4
(define-fun memory17 () Mem (write32 memory16 |%3_@exp1| |%b_@exp1|))
;; store i32 1, i32* %retval, align 4
(define-fun memory18 () Mem (write32 memory17 |%retval_@exp1| (_ bv1 32)))
;; %4 = load i32* %3, align 4
(define-fun |%4_@exp1| () (_ BitVec 32) (read32 memory18 |%3_@exp1|))
;; %5 = icmp slt i32 %4, 0
(define-fun |%5_@exp1| () Bool (bvslt |%4_@exp1| (_ bv0 32)))
;; br i1 %5, label %6, label %7
;; No backward arrows

;; BLOCK %6 with index 1 and rank = 2
;; Predecessors: %0
;; @exp1_block_1_entry_condition 
(define-fun @exp1_block_1_entry_condition () Bool
    (and @exp1_block_0_entry_condition |%5_@exp1|)
)
;;Memory PHI
(define-fun memory19 () Mem memory18)
;; store i32 0, i32* %1
(define-fun memory20 () Mem (write32 memory19 |%1_@exp1| (_ bv0 32)))
;; br label %27
;; No backward arrows

;; BLOCK %7 with index 2 and rank = 2
;; Predecessors: %0
;; @exp1_block_2_entry_condition 
(define-fun @exp1_block_2_entry_condition () Bool
    (and @exp1_block_0_entry_condition (not |%5_@exp1|))
)
;;Memory PHI
(define-fun memory21 () Mem memory18)
;; br label %8
;; No backward arrows

;; BLOCK %8 with index 3 and rank = 3
;; Predecessors: %19 %7
;; Backward pointers: %19
;; @exp1_block_3_entry_condition 
(define-fun @exp1_block_3_entry_condition () Bool
    @exp1_block_2_entry_condition
)
;;Memory PHI
(define-fun memory22 () Mem memory21)
;; %9 = load i32* %3, align 4
(define-fun |%9_@exp1| () (_ BitVec 32) (read32 memory22 |%3_@exp1|))
;; %10 = icmp ne i32 %9, 0
(define-fun |%10_@exp1| () Bool (distinct |%9_@exp1| (_ bv0 32)))
;; br i1 %10, label %11, label %25
;; No backward arrows

;; BLOCK %11 with index 4 and rank = 4
;; Predecessors: %8
;; @exp1_block_4_entry_condition 
(define-fun @exp1_block_4_entry_condition () Bool
    (and @exp1_block_3_entry_condition |%10_@exp1|)
)
;;Memory PHI
(define-fun memory23 () Mem memory22)
;; %12 = load i32* %3, align 4
(define-fun |%12_@exp1| () (_ BitVec 32) (read32 memory23 |%3_@exp1|))
;; %13 = and i32 %12, 1
(define-fun |%13_@exp1| () (_ BitVec 32) (bvand |%12_@exp1| (_ bv1 32)))
;; %14 = icmp ne i32 %13, 0
(define-fun |%14_@exp1| () Bool (distinct |%13_@exp1| (_ bv0 32)))
;; br i1 %14, label %15, label %19
;; No backward arrows

;; BLOCK %25 with index 7 and rank = 4
;; Predecessors: %8
;; @exp1_block_7_entry_condition 
(define-fun @exp1_block_7_entry_condition () Bool
    (and @exp1_block_3_entry_condition (not |%10_@exp1|))
)
;;Memory PHI
(define-fun memory24 () Mem memory22)
;; %26 = load i32* %retval, align 4
(define-fun |%26_@exp1| () (_ BitVec 32) (read32 memory24 |%retval_@exp1|))
;; store i32 %26, i32* %1
(define-fun memory25 () Mem (write32 memory24 |%1_@exp1| |%26_@exp1|))
;; br label %27
;; No backward arrows

;; BLOCK %15 with index 5 and rank = 5
;; Predecessors: %11
;; @exp1_block_5_entry_condition 
(define-fun @exp1_block_5_entry_condition () Bool
    (and @exp1_block_4_entry_condition |%14_@exp1|)
)
;;Memory PHI
(define-fun memory26 () Mem memory23)
;; %16 = load i32* %2, align 4
(define-fun |%16_@exp1| () (_ BitVec 32) (read32 memory26 |%2_@exp1|))
;; %17 = load i32* %retval, align 4
(define-fun |%17_@exp1| () (_ BitVec 32) (read32 memory26 |%retval_@exp1|))
;; %18 = mul nsw i32 %17, %16
(define-fun |%18_@exp1| () (_ BitVec 32) (bvmul |%17_@exp1| |%16_@exp1|))
;; store i32 %18, i32* %retval, align 4
(define-fun memory27 () Mem (write32 memory26 |%retval_@exp1| |%18_@exp1|))
;; br label %19
;; No backward arrows

;; BLOCK %27 with index 8 and rank = 5
;; Predecessors: %25 %6
;; @exp1_block_8_entry_condition 
(define-fun @exp1_block_8_entry_condition () Bool
    (or
        @exp1_block_7_entry_condition
        @exp1_block_1_entry_condition
    )
)
;;Memory PHI
(define-fun memory28 () Mem 
    (ite @exp1_block_7_entry_condition memory25 memory20
    ))
;; %28 = load i32* %1
(define-fun |%28_@exp1| () (_ BitVec 32) (read32 memory28 |%1_@exp1|))
;; ret i32 %28
;; No backward arrows

;; BLOCK %19 with index 6 and rank = 6
;; Predecessors: %15 %11
;; @exp1_block_6_entry_condition 
(define-fun @exp1_block_6_entry_condition () Bool
    (or
        @exp1_block_5_entry_condition
        (and @exp1_block_4_entry_condition (not |%14_@exp1|))
    )
)
;;Memory PHI
(define-fun memory29 () Mem 
    (ite @exp1_block_5_entry_condition memory27 memory23
    ))
;; %20 = load i32* %3, align 4
(define-fun |%20_@exp1| () (_ BitVec 32) (read32 memory29 |%3_@exp1|))
;; %21 = ashr i32 %20, 1
(define-fun |%21_@exp1| () (_ BitVec 32) (bvashr |%20_@exp1| (_ bv1 32)))
;; store i32 %21, i32* %3, align 4
(define-fun memory30 () Mem (write32 memory29 |%3_@exp1| |%21_@exp1|))
;; %22 = load i32* %2, align 4
(define-fun |%22_@exp1| () (_ BitVec 32) (read32 memory30 |%2_@exp1|))
;; %23 = load i32* %2, align 4
(define-fun |%23_@exp1| () (_ BitVec 32) (read32 memory30 |%2_@exp1|))
;; %24 = mul nsw i32 %23, %22
(define-fun |%24_@exp1| () (_ BitVec 32) (bvmul |%23_@exp1| |%22_@exp1|))
;; store i32 %24, i32* %2, align 4
(define-fun memory31 () Mem (write32 memory30 |%2_@exp1| |%24_@exp1|))
;; br label %8
;; BACKWARD ARROWS:  %8
(assert 
    (not @exp1_block_6_entry_condition)
)


(define-fun @exp1_result () (_ BitVec 32) |%28_@exp1|)

;; Function: |@main|
;; (i32 %argc, i8** %argv)
(declare-fun memory32 () Mem)
(define-fun rsp11 () (_ BitVec 64) (_ bv0 64))
(declare-fun |%argc_@main| () (_ BitVec 32))
(declare-fun |%argv_@main| () (_ BitVec 64))

;; BLOCK %0 with index 0 and rank = 1
;; Predecessors:
;; @main_block_0_entry_condition 
(define-fun @main_block_0_entry_condition () Bool true)
;; %1 = alloca i32, align 4
(define-fun rsp12 () Address (bvsub rsp11 (_ bv4 64)))
(define-fun |%1_@main| () (_ BitVec 64) rsp12)
;; %2 = alloca i32, align 4
(define-fun rsp13 () Address (bvsub rsp12 (_ bv4 64)))
(define-fun |%2_@main| () (_ BitVec 64) rsp13)
;; %3 = alloca i8**, align 8
(define-fun rsp14 () Address (bvsub rsp13 (_ bv8 64)))
(define-fun |%3_@main| () (_ BitVec 64) rsp14)
;; store i32 0, i32* %1
(define-fun memory33 () Mem (write32 memory32 |%1_@main| (_ bv0 32)))
;; store i32 %argc, i32* %2, align 4
(define-fun memory34 () Mem (write32 memory33 |%2_@main| |%argc_@main|))
;; store i8** %argv, i8*** %3, align 8
(define-fun memory35 () Mem (write64 memory34 |%3_@main| |%argv_@main|))
;; ret i32 0
;; No backward arrows


(define-fun @main_result () (_ BitVec 32) (_ bv0 32))

