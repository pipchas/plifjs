--------------------------- MODULE RuntimeFS--------------------------------
EXTENDS ParametersFS
----------------------------------------------------------------------------
(***************************************************************************)
(* The first argument is a set of locks to be opened.  ReduceSet is used   *)
(* to iterate over the set of locks,                                       *)
(***************************************************************************)

openLock (id, locks) ==
       SLocks' = [SLocks EXCEPT ![id] =
       FoldSet (LAMBDA X, y: 
                      LET OSet == COpenLocks(y, GPol)
                      IN  [x1 \in DOMAIN X |-> (X[x1] \cup
                          IF x1 \in DOMAIN OSet 
                             THEN 
                                IF x1 \in E1 
                                    THEN {OSet[x1]}
                                    ELSE {OSet[x1]}   
                             ELSE {}) \ {NONE}], StateE, locks)]

(***************************************************************************)
(* updates columns policies with respect to pvalues, the current context   *)
(* security label and the where_cond security label                        *)
(***************************************************************************)

UpdateTablePolicy (id, columns, pvalues, cond) ==
  LET D == DOMAIN columns
    IN
  LET
        UpdateTablePolicy_OP(x,y)== 
        [x EXCEPT ![y]["policy"] = 
            LUB4Seq(Sessions[id]["PCLabel"] 
                    \o <<x[y]["policy"]>> \o <<pvalues[CHOOSE i \in 
                         D : y = columns[i]]>> \o <<cond>>)]        
  IN
  FoldSeq(UpdateTablePolicy_OP, VPol, columns)
  

DeleteTablePolicy (id, columns, cond) ==
  LET
        DeleteTablePolicy_OP(x,y)== 
        [x EXCEPT ![y]["policy"] = 
            LUB4Seq(Sessions[id]["PCLabel"] 
                    \o <<x[y]["policy"]>> \o <<cond>>)]        
  IN
  FoldSeq(DeleteTablePolicy_OP, VPol, columns)

(***************************************************************************)
(* updates session vars policies with respect to pvalues, the current      *)
(* context security label and the where_cond security label                *)
(***************************************************************************)


UpdateVarPolicy (id, variables, exprs, cond) ==
  LET D == DOMAIN variables
    IN
  LET   
    UpdateVarPolicy_OP(x,y) == 
        [x EXCEPT ![Head(Sessions[id]["StateRegs"]).fp + y.offs] = 
            LUB4Seq(Sessions[id]["PCLabel"] 
                    \o <<exprs[CHOOSE i \in 
                         D : y = variables[i]]>> \o <<cond>>)]  
  IN
  FoldSeq(UpdateVarPolicy_OP, Sessions[id]["SessionM"], variables)

(***************************************************************************)
(* updates caller block (preceding block) vars policies when return from a *)
(* callee function                                                         *)
(***************************************************************************)

UpdateOuterVarPolicy (id, variables, exprs, cond) ==
  LET D == DOMAIN variables
    IN
  LET
    UpdateOuterVarPolicy_OP(x,y) == 
        [x EXCEPT ![Head(Tail(Sessions[id]["StateRegs"])).fp + y.offs] = 
           LUB4Seq(Sessions[id]["PCLabel"] 
                    \o <<exprs[CHOOSE i \in 
                         D : y = variables[i]]>> \o <<cond>>)]
  IN
  FoldSeq(UpdateOuterVarPolicy_OP, Sessions[id]["SessionM"], variables)    

(***************************************************************************)
(* the instrumented operational semantics                                  *)
(***************************************************************************)

(***************************************************************************)
(* flow operator implements FLOW abstarct semantics rules                  *)
(***************************************************************************)

flow(id, variables, exprs, cond, next_stmt, isColumn) ==
    
 IF isColumn
  THEN
    LET isExt == IF VPol[variables[1]]["ext"] = 1
                    THEN TRUE 
                    ELSE FALSE
    IN
    IF isExt
       THEN
           /\ New2Old' = <<FoldSeq(LAMBDA x,y: x \o <<VPol[y]["policy"]>>, 
                                                             <<>>, variables), 
                           FoldSeq(LAMBDA x,y: x \o 
                           <<LUB4Seq(Sessions[id]["PCLabel"] 
                                   \o <<cond>> \o <<y>>)>>, <<>>, exprs)>>
           /\ Sessions' = 
               [Sessions EXCEPT ![id]["StateRegs"] = 
                           <<[Head(Sessions[id]["StateRegs"]) 
                                    EXCEPT !["pc"] = next_stmt]>> \o
                                            Tail(Sessions[id]["StateRegs"])]
           /\ VPol' = VPol
            
       ELSE 
           /\ New2Old' = << <<max>>,<<min>> >>
           /\ Sessions' = 
               [Sessions EXCEPT ![id]["StateRegs"] = 
                           <<[Head(Sessions[id]["StateRegs"]) 
                                    EXCEPT !["pc"] = next_stmt]>> \o
                                            Tail(Sessions[id]["StateRegs"])]
           /\ VPol'  = UpdateTablePolicy (id, variables, exprs, cond)
  ELSE
   /\ New2Old' = << <<max>>, <<min>> >>
    /\ Sessions' = 
       [Sessions EXCEPT ![id]["StateRegs"] = 
        <<[Head(Sessions[id]["StateRegs"]) EXCEPT !["pc"] = next_stmt]>> \o
            Tail(Sessions[id]["StateRegs"]),
                        ![id]["SessionM"] = 
                               UpdateVarPolicy (id, variables, exprs, cond)]
    /\ VPol'=VPol   
           
(***************************************************************************)
(* load operator reads a label from the stack like session memory          *)
(***************************************************************************)

load(id, ptr) == 
      Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + ptr.offs]
      
(***************************************************************************)
(* adds the policy of the if expression into PClabel                       *)
(***************************************************************************)

if(id, policy, next_stmt) == 
    /\ Sessions'  = 
        [Sessions 
            EXCEPT ![id]["PCLabel"] = <<policy>> \o Sessions[id]["PCLabel"],
                   ![id]["StateRegs"] = 
                    <<[Head(Sessions[id]["StateRegs"]) 
                                            EXCEPT !["pc"] = next_stmt]>> \o
                          Tail(Sessions[id]["StateRegs"])]

(***************************************************************************)
(* removes from PClabel a policy of the last if expression                 *)
(***************************************************************************)

ifend (id, next_stmt) == 
    /\ Sessions'  = 
            [Sessions 
                EXCEPT ![id]["PCLabel"] = Tail(Sessions[id]["PCLabel"]),
                       ![id]["StateRegs"] = 
                        <<[Head(Sessions[id]["StateRegs"]) 
                                            EXCEPT !["pc"] = next_stmt]>> \o
                          Tail(Sessions[id]["StateRegs"])]

(***************************************************************************)
(* call operator implements C-PROC abstarct semantics rules                *)
(***************************************************************************)

call (id, next_stmt, lbl_ret, exprs) ==
   /\ Sessions' = [Sessions EXCEPT ![id]["SessionM"] = 
             Sessions[id]["SessionM"] \o exprs,
                                   ![id]["StateRegs"] =
                                  
             \* заменяем в старом frame значение pc     
             \* то есть задаем адрес возврата             
                                     
             <<[pc |-> next_stmt, 
                fp |-> Len(Sessions[id]["SessionM"])+1]>> \o
             <<[pc |-> <<Head(Sessions[id]["StateRegs"])["pc"][1], lbl_ret>>, 
                fp |-> Head(Sessions[id]["StateRegs"])["fp"]]>> \o
             Tail(Sessions[id]["StateRegs"]) 
             ] 

(***************************************************************************)
(* exit_call implements assignment to a variable after returning from a    *)
(* function                                                                *)
(***************************************************************************)

exit_call(id, variables, next_stmt, isColumn) ==
  IF isColumn
  THEN  
    /\ New2Old' = << <<max>>, <<min>> >>
    /\ Sessions' = 
       [Sessions EXCEPT ![id]["StateRegs"] = 
        <<[Head(Sessions[id]["StateRegs"]) EXCEPT !["pc"] = next_stmt]>> \o
            Tail(Sessions[id]["StateRegs"]),
                        ![id]["SessionM"] = 
                    UpdateTablePolicy (id, variables, Sessions[id]["Ret"], min)
       ]
  ELSE
    /\ New2Old' = << <<max>>, <<min>> >>
    /\ Sessions' = 
       [Sessions EXCEPT ![id]["StateRegs"] = 
        <<[Head(Sessions[id]["StateRegs"]) EXCEPT !["pc"] = next_stmt]>> \o
            Tail(Sessions[id]["StateRegs"]),
                        ![id]["SessionM"] = 
                    UpdateVarPolicy (id, variables, Sessions[id]["Ret"], min)
       ]

(***************************************************************************)
(* return operator implements C-RET, C-EXT-RET abstarct semantics rules    *)
(***************************************************************************)

return (id, ret_vars, exprs, next_stmt) ==

    \* Если в стеке сеанса единственный frame, то функция является внешней.
    \* Альтернативный вариант проверки: Head(Sessions[id]["StateRegs"]["fp"]=1) 
    
    LET isExt == IF Len(Sessions[id]["StateRegs"])=1
                    THEN TRUE 
                    ELSE FALSE
    IN
    IF isExt
       THEN
           /\ New2Old' = <<FoldSeq(LAMBDA x,y: x \o <<y["policy"]>>, 
                                                            <<>>, ret_vars), 
                           FoldSeq(LAMBDA x,y: x \o 
                           <<LUB4Seq(Sessions[id]["PCLabel"] 
                                            \o <<y>>)>>, <<>>, exprs)>>
           /\ Sessions' = 
               [Sessions EXCEPT ![id]["StateRegs"] = 
                                <<[Head(Sessions[id]["StateRegs"]) 
                                            EXCEPT !["pc"] = next_stmt]>> \o
                Tail(Sessions[id]["StateRegs"])]
            
       ELSE 
           /\ New2Old' = << <<max>>,<<min>> >>
           /\ Sessions' = 
               [Sessions EXCEPT ![id]["StateRegs"] = 
                                <<[Head(Sessions[id]["StateRegs"]) 
                                            EXCEPT !["pc"] = next_stmt]>> \o
                                            Tail(Sessions[id]["StateRegs"]),
                                ![id]["SessionM"] = 
                                UpdateVarPolicy(id, ret_vars, exprs, min)
                ]

(***************************************************************************)
(* skip operator implements C-NULL abstarct semantics rule                 *)
(***************************************************************************)

skip(id, next_stmt) == 
    /\ Sessions'  = 
        [Sessions EXCEPT ![id]["StateRegs"] = 
            <<[Head(Sessions[id]["StateRegs"]) 
                                            EXCEPT !["pc"] = next_stmt]>> \o
                          Tail(Sessions[id]["StateRegs"])]

(***************************************************************************)
(* Safety Inv                                                              *)
(***************************************************************************)
(*                 
ParalocksInv == 
    LET
        \* @type: (Bool, <<POLICY, Int>>) => Bool;
        ParalocksInv_OP1(x, y) ==
            x /\ comparePol(ALSTP(New2Old[2][y[2]], StateE), y[1])
    IN
    LET 
        \* @type: (Seq(<<POLICY, Int>>), POLICY) => Seq(<<POLICY, Int>>);
        ParalocksInv_OP2(x1, y1) == 
                    <<<<Head(x1)[1], Head(x1)[2] + 1>>>> 
                                 \o Tail (x1) \o <<<<y1, Head(x1)[2] + 1>>>>
    IN
    IF  Ignore # 1
        THEN 
             FoldSeq(ParalocksInv_OP1, TRUE, 
             Tail(FoldSeq(ParalocksInv_OP2, <<<<min, 0>>>>, New2Old[1]))) 
        ELSE TRUE
*)

ParalocksInv == 
    LET
        \* @type: (Bool, <<POLICY, Int>>) => Bool;
        ParalocksInv_OP1(x, y) ==
            x /\ comparePol(New2Old[2][y[2]], ALSTP(y[1], StateE))
    IN
    LET 
        \* @type: (Seq(<<POLICY, Int>>), POLICY) => Seq(<<POLICY, Int>>);
        ParalocksInv_OP2(x1, y1) == 
                    <<<<Head(x1)[1], Head(x1)[2] + 1>>>> 
                                 \o Tail (x1) \o <<<<y1, Head(x1)[2] + 1>>>>
    IN
    IF  Ignore # 1
        THEN 
             FoldSeq(ParalocksInv_OP1, TRUE, 
             Tail(FoldSeq(ParalocksInv_OP2, <<<<min, 0>>>>, New2Old[1]))) 
        ELSE TRUE

VPolUnchanged ==  
    LET CompInv_OP1 (x, y) == /\ x
                              /\ comparePol(VPol[y].policy, VPol'[y].policy)
                              /\ comparePol(VPol'[y].policy, VPol[y].policy)
    IN FoldSet(CompInv_OP1, TRUE, DOMAIN VPol)

CompInv == [] [VPolUnchanged]_vars 

===========================================================================
