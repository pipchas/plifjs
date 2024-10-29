----------------------- MODULE Main -----------------------

EXTENDS RuntimeFS, Sequences

p_allocate_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                     <<p_allocate_p_s_id(id).policy,
                       p_allocate_l_v_is_acc(id).policy,
                       p_allocate_l_v_p_id(id).policy,
                       p_allocate_p_id(id).policy,
                       p_allocate_p_sec_id(id).policy,
                       p_allocate_p_alloc_date(id).policy,
                       p_allocate_l_paper_not_accepted(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<p_allocate_p_s_id(id).policy,
                       p_allocate_l_v_is_acc(id).policy,
                       p_allocate_l_v_p_id(id).policy,
                       p_allocate_p_id(id).policy,
                       p_allocate_p_sec_id(id).policy,
                       p_allocate_p_alloc_date(id).policy,
                       p_allocate_l_paper_not_accepted(id).policy>>,
                       <<any_caller(id),
                       p_allocate_l_v_is_acc(id).policy,
                       p_allocate_l_v_p_id(id).policy,
                       any_caller(id),
                       any_caller(id),
                       any_caller(id),
                       p_allocate_l_paper_not_accepted(id).policy>>
                    >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


p_allocate2_1(id) ==
    /\ call(id, <<"f_is_accepted", "lbl_2">>,
                "lbl_2_1_exit_call",
                <<load(id, p_allocate_p_s_id(id)),
                  f_is_accepted_l_v_status(id).policy,
                  f_is_accepted_r_const(id).policy>>)
    /\ Trace' = Append(Trace, <<id, "p_allocate2_1">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED <<XLocks, VPol, New2Old>>

p_allocate2_1_exit_call(id) ==
/\ exit_call(id, <<p_allocate_l_v_is_acc(id)>>,
                 <<"p_allocate", "lbl_4_7">>, FALSE)
    /\ Trace' = Append(Trace,<<id, "p_allocate2_1_exit_call">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED <<XLocks, VPol>>

p_allocate4(id) ==
    /\ if(id, LUB4Seq(<<load(id, p_allocate_l_v_is_acc(id))>>),
                      <<
                      "p_allocate", "lbl_4_7_skip"
                      >>)
    /\ Trace' = Append(Trace,<<id, "p_allocate4">>)
    /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore>>

p_allocate_4_7_skip(id) ==
    \/ /\ skip(id, <<"p_allocate", "lbl_5">>)
     /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore, Trace>>
    \/ /\ skip(id, <<"p_allocate", "lbl_8">>)
     /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore, Trace>>


p_allocate_4_7_ifend(id) ==
    /\ ifend(id, <<"p_allocate", "lbl_10_12">>)
    /\ Trace' = Append(Trace,<<id, "p_allocate_4_7_ifend">>)
    /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore>>




p_allocate5(id) ==
    /\  flow(id, <<p_allocate_l_v_p_id(id)>>,
                 <<VPol["submissions_paper_id"].policy>>,
                 LUB4Seq(<<
                   VPol["submissions_submission_id"].policy,
                   load(id, p_allocate_p_s_id(id))>>),
                 <<"p_allocate","lbl_6">>, FALSE)
    /\ Trace'  = Append(Trace, <<id, "p_allocate5">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks

p_allocate6(id) ==
    /\  flow(id, <<"allocations_allocation_id",
                   "allocations_submission_id",
                   "allocations_section_id",
                   "allocations_allocation_date">>,
                 <<load(id, p_allocate_p_id(id)),
                   load(id, p_allocate_p_s_id(id)),
                   load(id, p_allocate_p_sec_id(id)),
                   load(id, p_allocate_p_alloc_date(id))>>,
                 min,
                 <<"p_allocate","lbl_4_7_ifend">>, TRUE)
    /\ Trace'  = Append(Trace, <<id, "p_allocate6">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks

p_allocate8(id) ==
    /\  flow(id, <<p_allocate_l_paper_not_accepted(id)>>,
                 <<LUB4Seq(<<load(id, p_allocate_l_v_is_acc(id)),
                   load(id, p_allocate_l_paper_not_accepted(id))>>)>>,
                 min,
                 <<"p_allocate","lbl_4_7_ifend">>, FALSE)
    /\ Trace'  = Append(Trace, <<id, "p_allocate8">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks

p_allocate10(id) ==
    /\ if(id, LUB4Seq(<<load(id, p_allocate_l_paper_not_accepted(id))>>),
                      <<
                      "p_allocate", "lbl_10_12_skip"
                      >>)
    /\ Trace' = Append(Trace,<<id, "p_allocate10">>)
    /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore>>

p_allocate_10_12_skip(id) ==
    \/ /\ skip(id, <<"p_allocate", "lbl_11">>)
     /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore, Trace>>
    \/ /\ skip(id, <<"p_allocate", "lbl_10_12_ifend">>)
     /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore, Trace>>


p_allocate_10_12_ifend(id) ==
    /\ ifend(id, <<"p_allocate", "exit">>)
    /\ Trace' = Append(Trace,<<id, "p_allocate_10_12_ifend">>)
    /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore>>

p_allocate11(id) ==
    /\  flow(id, <<"logs_event_id",
                   "logs_err_info">>,
                 <<min,
                   load(id, p_allocate_p_s_id(id))>>,
                 min,
                 <<"p_allocate","lbl_10_12_ifend">>, TRUE)
    /\ Trace'  = Append(Trace, <<id, "p_allocate11">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks


p_allocate_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 7)]
     /\ Trace'  = Append(Trace, <<id, "p_allocate_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

p_allocate(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2_1"   -> p_allocate2_1(id)
    [] Head(st).pc[2] = "lbl_2_1_exit_call"   -> p_allocate2_1_exit_call(id)
    [] Head(st).pc[2] = "lbl_4_7"   -> p_allocate4(id)
    [] Head(st).pc[2] = "lbl_4_7_skip"   -> p_allocate_4_7_skip(id)
    [] Head(st).pc[2] = "lbl_4_7_ifend"   -> p_allocate_4_7_ifend(id)
    [] Head(st).pc[2] = "lbl_5"   -> p_allocate5(id)
    [] Head(st).pc[2] = "lbl_6"   -> p_allocate6(id)
    [] Head(st).pc[2] = "lbl_8"   -> p_allocate8(id)
    [] Head(st).pc[2] = "lbl_10_12"   -> p_allocate10(id)
    [] Head(st).pc[2] = "lbl_10_12_skip"   -> p_allocate_10_12_skip(id)
    [] Head(st).pc[2] = "lbl_10_12_ifend"   -> p_allocate_10_12_ifend(id)
    [] Head(st).pc[2] = "lbl_11"   -> p_allocate11(id)
    [] Head(st).pc[2] = "exit"    -> p_allocate_exit(id)
    [] OTHER -> UNCHANGED vars


f_get_paper_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                     <<f_get_paper_l_v_paper_paper_id(id).policy,
                       f_get_paper_l_v_paper_title(id).policy,
                       f_get_paper_l_v_paper_abstract(id).policy,
                       f_get_paper_l_v_paper_text(id).policy,
                       f_get_paper_l_v_paper_authors(id).policy,
                       f_get_paper_p_p_id(id).policy,
                       f_get_paper_r_v_paper_paper_id(id).policy,
                       f_get_paper_r_v_paper_title(id).policy,
                       f_get_paper_r_v_paper_abstract(id).policy,
                       f_get_paper_r_v_paper_text(id).policy,
                       f_get_paper_r_v_paper_authors(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<f_get_paper_l_v_paper_paper_id(id).policy,
                       f_get_paper_l_v_paper_title(id).policy,
                       f_get_paper_l_v_paper_abstract(id).policy,
                       f_get_paper_l_v_paper_text(id).policy,
                       f_get_paper_l_v_paper_authors(id).policy,
                       f_get_paper_p_p_id(id).policy,
                       f_get_paper_r_v_paper_paper_id(id).policy,
                       f_get_paper_r_v_paper_title(id).policy,
                       f_get_paper_r_v_paper_abstract(id).policy,
                       f_get_paper_r_v_paper_text(id).policy,
                       f_get_paper_r_v_paper_authors(id).policy>>,
                     <<f_get_paper_l_v_paper_paper_id(id).policy,
                       f_get_paper_l_v_paper_title(id).policy,
                       f_get_paper_l_v_paper_abstract(id).policy,
                       f_get_paper_l_v_paper_text(id).policy,
                       f_get_paper_l_v_paper_authors(id).policy,
                       any_caller(id),
                       f_get_paper_r_v_paper_paper_id(id).policy,
                       f_get_paper_r_v_paper_title(id).policy,
                       f_get_paper_r_v_paper_abstract(id).policy,
                       f_get_paper_r_v_paper_text(id).policy,
                       f_get_paper_r_v_paper_authors(id).policy>>
                    >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


f_get_paper2(id) ==
    /\  flow(id, <<f_get_paper_l_v_paper_paper_id(id),
                   f_get_paper_l_v_paper_title(id),
                   f_get_paper_l_v_paper_abstract(id),
                   f_get_paper_l_v_paper_text(id),
                   f_get_paper_l_v_paper_authors(id)>>,
                 <<VPol["papers_paper_id"].policy,
                   VPol["papers_title"].policy,
                   VPol["papers_abstract"].policy,
                   VPol["papers_text"].policy,
                   VPol["papers_authors"].policy>>,
                 LUB4Seq(<<
                   VPol["papers_paper_id"].policy,
                   load(id, f_get_paper_p_p_id(id))>>),
                 <<"f_get_paper","lbl_7">>, FALSE)
    /\ Trace'  = Append(Trace, <<id, "f_get_paper2">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks

f_get_paper7(id) ==
    /\ return(id, <<f_get_paper_r_v_paper_paper_id(id),
                    f_get_paper_r_v_paper_title(id),
                    f_get_paper_r_v_paper_abstract(id),
                    f_get_paper_r_v_paper_text(id),
                    f_get_paper_r_v_paper_authors(id)>>,
                  <<load(id, f_get_paper_l_v_paper_paper_id(id)),
                    load(id, f_get_paper_l_v_paper_title(id)),
                    load(id, f_get_paper_l_v_paper_abstract(id)),
                    load(id, f_get_paper_l_v_paper_text(id)),
                    load(id, f_get_paper_l_v_paper_authors(id))>>,
                  <<"f_get_paper", "exit">>)
    /\ Trace' = Append(Trace,<<id, "f_get_paper7">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks
    /\ VPol' = VPol


f_get_paper_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["Ret"] =
     <<Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_paper_r_v_paper_paper_id(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_paper_r_v_paper_title(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_paper_r_v_paper_abstract(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_paper_r_v_paper_text(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_paper_r_v_paper_authors(id).offs]>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 11)]
     /\ Trace'  = Append(Trace, <<id, "f_get_paper_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

f_get_paper(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2"   -> f_get_paper2(id)
    [] Head(st).pc[2] = "lbl_7"   -> f_get_paper7(id)
    [] Head(st).pc[2] = "exit"    -> f_get_paper_exit(id)
    [] OTHER -> UNCHANGED vars


f_get_section_program_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                     <<f_get_section_program_l_v_program_paper_id(id).policy,
                       f_get_section_program_l_v_program_title(id).policy,
                       f_get_section_program_l_v_program_abstract(id).policy,
                       f_get_section_program_l_v_program_text(id).policy,
                       f_get_section_program_l_v_program_authors(id).policy,
                       f_get_section_program_p_s_id(id).policy,
                       f_get_section_program_r_v_program_paper_id(id).policy,
                       f_get_section_program_r_v_program_title(id).policy,
                       f_get_section_program_r_v_program_abstract(id).policy,
                       f_get_section_program_r_v_program_text(id).policy,
                       f_get_section_program_r_v_program_authors(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<f_get_section_program_l_v_program_paper_id(id).policy,
                       f_get_section_program_l_v_program_title(id).policy,
                       f_get_section_program_l_v_program_abstract(id).policy,
                       f_get_section_program_l_v_program_text(id).policy,
                       f_get_section_program_l_v_program_authors(id).policy,
                       f_get_section_program_p_s_id(id).policy,
                       f_get_section_program_r_v_program_paper_id(id).policy,
                       f_get_section_program_r_v_program_title(id).policy,
                       f_get_section_program_r_v_program_abstract(id).policy,
                       f_get_section_program_r_v_program_text(id).policy,
                       f_get_section_program_r_v_program_authors(id).policy>>,
                     <<f_get_section_program_l_v_program_paper_id(id).policy,
                       f_get_section_program_l_v_program_title(id).policy,
                       f_get_section_program_l_v_program_abstract(id).policy,
                       f_get_section_program_l_v_program_text(id).policy,
                       f_get_section_program_l_v_program_authors(id).policy,
                       any_caller(id),
                       f_get_section_program_r_v_program_paper_id(id).policy,
                       f_get_section_program_r_v_program_title(id).policy,
                       f_get_section_program_r_v_program_abstract(id).policy,
                       f_get_section_program_r_v_program_text(id).policy,
                       f_get_section_program_r_v_program_authors(id).policy>>
                    >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


f_get_section_program2(id) ==
    /\  flow(id, <<f_get_section_program_l_v_program_paper_id(id),
                   f_get_section_program_l_v_program_title(id),
                   f_get_section_program_l_v_program_abstract(id),
                   f_get_section_program_l_v_program_text(id),
                   f_get_section_program_l_v_program_authors(id)>>,
                 <<VPol["papers_paper_id"].policy,
                   VPol["papers_title"].policy,
                   VPol["papers_abstract"].policy,
                   VPol["papers_text"].policy,
                   min>>,
                 LUB4Seq(<<
                   VPol["papers_paper_id"].policy,
                   VPol["submissions_paper_id"].policy,
                   VPol["allocations_section_id"].policy,
                   load(id, f_get_section_program_p_s_id(id))>>),
                 <<"f_get_section_program","lbl_6">>, FALSE)
    /\ Trace'  = Append(Trace, <<id, "f_get_section_program2">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks

f_get_section_program6(id) ==
    /\ return(id, <<f_get_section_program_r_v_program_paper_id(id),
                    f_get_section_program_r_v_program_title(id),
                    f_get_section_program_r_v_program_abstract(id),
                    f_get_section_program_r_v_program_text(id),
                    f_get_section_program_r_v_program_authors(id)>>,
                  <<load(id, f_get_section_program_l_v_program_paper_id(id)),
                    load(id, f_get_section_program_l_v_program_title(id)),
                    load(id, f_get_section_program_l_v_program_abstract(id)),
                    load(id, f_get_section_program_l_v_program_text(id)),
                    load(id, f_get_section_program_l_v_program_authors(id))>>,
                  <<"f_get_section_program", "exit">>)
    /\ Trace' = Append(Trace,<<id, "f_get_section_program6">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks
    /\ VPol' = VPol


f_get_section_program_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["Ret"] =
     <<Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_section_program_r_v_program_paper_id(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_section_program_r_v_program_title(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_section_program_r_v_program_abstract(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_section_program_r_v_program_text(id).offs],
       Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_get_section_program_r_v_program_authors(id).offs]>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 11)]
     /\ Trace'  = Append(Trace, <<id, "f_get_section_program_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

f_get_section_program(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2"   -> f_get_section_program2(id)
    [] Head(st).pc[2] = "lbl_6"   -> f_get_section_program6(id)
    [] Head(st).pc[2] = "exit"    -> f_get_section_program_exit(id)
    [] OTHER -> UNCHANGED vars


f_is_accepted_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                     <<f_is_accepted_l_v_status(id).policy,
                       f_is_accepted_p_s_id(id).policy,
                       f_is_accepted_r_const(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<f_is_accepted_l_v_status(id).policy,
                       f_is_accepted_p_s_id(id).policy,
                       f_is_accepted_r_const(id).policy>>,
                     <<f_is_accepted_l_v_status(id).policy,
                       any_caller(id),
                       f_is_accepted_r_const(id).policy>>
                    >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


f_is_accepted2(id) ==
    /\  flow(id, <<f_is_accepted_l_v_status(id)>>,
                 <<VPol["submissions_status"].policy>>,
                 LUB4Seq(<<
                   VPol["submissions_submission_id"].policy,
                   load(id, f_is_accepted_p_s_id(id))>>),
                 <<"f_is_accepted","lbl_3_5">>, FALSE)
    /\ Trace'  = Append(Trace, <<id, "f_is_accepted2">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks

f_is_accepted3(id) ==
    /\ if(id, LUB4Seq(<<load(id, f_is_accepted_l_v_status(id))>>),
                      <<
                      "f_is_accepted", "lbl_3_5_skip"
                      >>)
    /\ Trace' = Append(Trace,<<id, "f_is_accepted3">>)
    /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore>>

f_is_accepted_3_5_skip(id) ==
    \/ /\ skip(id, <<"f_is_accepted", "lbl_4">>)
     /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore, Trace>>
    \/ /\ skip(id, <<"f_is_accepted", "lbl_6">>)
     /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore, Trace>>

f_is_accepted_3_5_ifend_ret(id) ==
    /\ ifend(id, <<"f_is_accepted", "exit">>)
    /\ Trace' = Append(Trace,<<id, "f_is_accepted_3_5_ifend_ret">>)
    /\ UNCHANGED <<StateE, New2Old, XLocks, VPol, SLocks, Ignore>>

f_is_accepted4(id) ==
    /\ return(id, <<f_is_accepted_r_const(id)>>,
                  <<min>>,
                  <<"f_is_accepted", "lbl_3_5_ifend_ret">>)
    /\ Trace' = Append(Trace,<<id, "f_is_accepted4">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks
    /\ VPol' = VPol

f_is_accepted6(id) ==
    /\ return(id, <<f_is_accepted_r_const(id)>>,
                  <<min>>,
                  <<"f_is_accepted", "lbl_3_5_ifend_ret">>)
    /\ Trace' = Append(Trace,<<id, "f_is_accepted6">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks
    /\ VPol' = VPol


f_is_accepted_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["Ret"] =
     <<Sessions[id]["SessionM"][Head(Sessions[id]["StateRegs"]).fp + f_is_accepted_r_const(id).offs]>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 3)]
     /\ Trace'  = Append(Trace, <<id, "f_is_accepted_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

f_is_accepted(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2"   -> f_is_accepted2(id)
    [] Head(st).pc[2] = "lbl_3_5"   -> f_is_accepted3(id)
    [] Head(st).pc[2] = "lbl_3_5_skip"   -> f_is_accepted_3_5_skip(id)
    [] Head(st).pc[2] = "lbl_3_5_ifend_ret"   -> f_is_accepted_3_5_ifend_ret(id)
    [] Head(st).pc[2] = "lbl_4"   -> f_is_accepted4(id)
    [] Head(st).pc[2] = "lbl_6"   -> f_is_accepted6(id)
    [] Head(st).pc[2] = "exit"    -> f_is_accepted_exit(id)
    [] OTHER -> UNCHANGED vars


p_add_paper_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                     <<p_add_paper_p_p_id(id).policy,
                       p_add_paper_p_tit(id).policy,
                       p_add_paper_p_absr(id).policy,
                       p_add_paper_p_t(id).policy,
                       p_add_paper_p_auth(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<p_add_paper_p_p_id(id).policy,
                       p_add_paper_p_tit(id).policy,
                       p_add_paper_p_absr(id).policy,
                       p_add_paper_p_t(id).policy,
                       p_add_paper_p_auth(id).policy>>,
                     <<any_caller(id),
                       any_caller(id),
                       any_caller(id),
                       any_caller(id),
                       any_caller(id)>>
                    >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


p_add_paper2(id) ==
    /\  flow(id, <<"papers_paper_id",
                   "papers_title",
                   "papers_abstract",
                   "papers_text",
                   "papers_authors">>,
                 <<load(id, p_add_paper_p_p_id(id)),
                   load(id, p_add_paper_p_tit(id)),
                   load(id, p_add_paper_p_absr(id)),
                   load(id, p_add_paper_p_t(id)),
                   load(id, p_add_paper_p_auth(id))>>,
                 min,
                 <<"p_add_paper","exit">>, TRUE)
    /\ Trace'  = Append(Trace, <<id, "p_add_paper2">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks


p_add_paper_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 5)]
     /\ Trace'  = Append(Trace, <<id, "p_add_paper_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

p_add_paper(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2"   -> p_add_paper2(id)
    [] Head(st).pc[2] = "exit"    -> p_add_paper_exit(id)
    [] OTHER -> UNCHANGED vars


p_submit_paper_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                     <<p_submit_paper_p_s_id(id).policy,
                       p_submit_paper_p_p_id(id).policy,
                       p_submit_paper_p_c_id(id).policy,
                       p_submit_paper_p_sub_date(id).policy,
                       p_submit_paper_p_stat(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<p_submit_paper_p_s_id(id).policy,
                       p_submit_paper_p_p_id(id).policy,
                       p_submit_paper_p_c_id(id).policy,
                       p_submit_paper_p_sub_date(id).policy,
                       p_submit_paper_p_stat(id).policy>>,
                     <<any_caller(id),
                       any_caller(id),
                       any_caller(id),
                       any_caller(id),
                       any_caller(id)>>
                    >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


p_submit_paper2(id) ==
    /\  flow(id, <<"submissions_submission_id",
                   "submissions_paper_id",
                   "submissions_conference_id",
                   "submissions_submission_date",
                   "submissions_status">>,
                 <<load(id, p_submit_paper_p_s_id(id)),
                   load(id, p_submit_paper_p_p_id(id)),
                   load(id, p_submit_paper_p_c_id(id)),
                   load(id, p_submit_paper_p_sub_date(id)),
                   load(id, p_submit_paper_p_stat(id))>>,
                 min,
                 <<"p_submit_paper","exit">>, TRUE)
    /\ Trace'  = Append(Trace, <<id, "p_submit_paper2">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks


p_submit_paper_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 5)]
     /\ Trace'  = Append(Trace, <<id, "p_submit_paper_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

p_submit_paper(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2"   -> p_submit_paper2(id)
    [] Head(st).pc[2] = "exit"    -> p_submit_paper_exit(id)
    [] OTHER -> UNCHANGED vars


p_change_status_load(id) ==
 IF XLocks = Undef
    THEN
    /\ XLocks' = id
    /\ Sessions'  = [Sessions EXCEPT ![id]["SessionM"] =
                     Sessions[id]["SessionM"] \o
                   <<p_change_status_p_stat(id).policy,
                     p_change_status_p_s_id(id).policy>>
                     ]
    /\ New2Old'   = <<
                     <<p_change_status_p_stat(id).policy,
                       p_change_status_p_s_id(id).policy>>,
                     <<any_caller(id),
                       any_caller(id)>>
                     >>
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ UNCHANGED  <<VPol>>
    ELSE UNCHANGED vars


p_change_status2(id) ==
    /\  flow(id, <<"submissions_status">>,
                 <<load(id, p_change_status_p_stat(id))>>,
                 LUB4Seq(<<
                   VPol["submissions_submission_id"].policy,
                   load(id, p_change_status_p_s_id(id))>>),
                 <<"p_change_status","exit">>, TRUE)
    /\ Trace'  = Append(Trace, <<id, "p_change_status2">>)
    /\ Ignore' = 0
    /\ SLocks' = SLocks
    /\ StateE' = SLocks'[id]
    /\ XLocks' = XLocks


p_change_status_exit(id) ==
    /\ IF Head(Sessions[id]["StateRegs"]).fp=1
        THEN  XLocks' = Undef
        ELSE  XLocks' = XLocks
    /\ Sessions'  =
     [Sessions EXCEPT
     ![id]["StateRegs"] = Tail(Sessions[id]["StateRegs"]) \o <<>>,
     ![id]["SessionM"] = SubSeq(Sessions[id]["SessionM"], 1,
                                       Len(Sessions[id]["SessionM"]) - 2)]
     /\ Trace'  = Append(Trace, <<id, "p_change_status_exit">>)
     /\ Ignore' = 0
     /\ SLocks' = SLocks
     /\ StateE' = SLocks'[id]
     /\ UNCHANGED <<New2Old, VPol>>

p_change_status(id,st)  ==
    CASE Head(st).pc[2] = "lbl_2"   -> p_change_status2(id)
    [] Head(st).pc[2] = "exit"    -> p_change_status_exit(id)
    [] OTHER -> UNCHANGED vars



dispatch(id,st) ==
    CASE
      /\ Head(st).pc[1] = "p_allocate"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ p_allocate_load (id)
         /\ Trace' = Append(Trace,<<id,"p_allocate_load">>)
      [] /\ Head(st).pc[1] = "p_allocate"
         /\ Sessions[id]["SessionM"] # <<>> -> p_allocate(id,st)

      [] Head(st).pc[1] = "f_get_paper"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ f_get_paper_load (id)
         /\ Trace' = Append(Trace,<<id,"f_get_paper_load">>)
      [] /\ Head(st).pc[1] = "f_get_paper"
         /\ Sessions[id]["SessionM"] # <<>> -> f_get_paper(id,st)

      [] Head(st).pc[1] = "f_get_section_program"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ f_get_section_program_load (id)
         /\ Trace' = Append(Trace,<<id,"f_get_section_program_load">>)
      [] /\ Head(st).pc[1] = "f_get_section_program"
         /\ Sessions[id]["SessionM"] # <<>> -> f_get_section_program(id,st)

      [] Head(st).pc[1] = "f_is_accepted"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ f_is_accepted_load (id)
         /\ Trace' = Append(Trace,<<id,"f_is_accepted_load">>)
      [] /\ Head(st).pc[1] = "f_is_accepted"
         /\ Sessions[id]["SessionM"] # <<>> -> f_is_accepted(id,st)

      [] Head(st).pc[1] = "p_add_paper"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ p_add_paper_load (id)
         /\ Trace' = Append(Trace,<<id,"p_add_paper_load">>)
      [] /\ Head(st).pc[1] = "p_add_paper"
         /\ Sessions[id]["SessionM"] # <<>> -> p_add_paper(id,st)

      [] Head(st).pc[1] = "p_submit_paper"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ p_submit_paper_load (id)
         /\ Trace' = Append(Trace,<<id,"p_submit_paper_load">>)
      [] /\ Head(st).pc[1] = "p_submit_paper"
         /\ Sessions[id]["SessionM"] # <<>> -> p_submit_paper(id,st)

      [] Head(st).pc[1] = "p_change_status"
      /\ Sessions[id]["SessionM"] = <<>> ->
         /\ p_change_status_load (id)
         /\ Trace' = Append(Trace,<<id,"p_change_status_load">>)
      [] /\ Head(st).pc[1] = "p_change_status"
         /\ Sessions[id]["SessionM"] # <<>> -> p_change_status(id,st)


(***************************************************************************)
(* The initial state.                                                      *)
(***************************************************************************)

Init ==

        LET sregs ==

                    {
                      <<[pc |-> <<"p_allocate", "lbl_2_1">>, fp |-> 1]>>,
                      <<[pc |-> <<"f_get_paper", "lbl_2">>, fp |-> 1]>>,
                      <<[pc |-> <<"f_get_section_program", "lbl_2">>, fp |-> 1]>>,
                      <<[pc |-> <<"f_is_accepted", "lbl_2">>, fp |-> 1]>>,
                      <<[pc |-> <<"p_add_paper", "lbl_2">>, fp |-> 1]>>,
                      <<[pc |-> <<"p_submit_paper", "lbl_2">>, fp |-> 1]>>,
                      <<[pc |-> <<"p_change_status", "lbl_2">>, fp |-> 1]>>
                    }

        IN

        /\ Trace     = <<>>
        /\ StateE    =  [e1 \in E0 |-> {}] @@ [e2 \in E1 |-> {}]
        /\ Sessions  \in
            [S ->
                FoldSet(LAMBDA x, y: x \cup
                    {y @@ [SessionM |-> <<>>]
                       @@ [PCLabel  |-> <<min>>]
                       @@ [Ret      |-> <<>>]},
                       {},
                       [{"StateRegs"} -> sregs])
            ]

        /\ SLocks   =
            [s \in S |-> [e1 \in E0 |-> {}]
             @@ [e2 \in E1 |-> 
                CASE 
                   /\ SelectSeq(Sessions[s]["StateRegs"],  
                         LAMBDA x : x["pc"][1]= "p_change_status") # <<>>
                   /\ \/ e2 = "reviewer"  
                      \/ e2 = "guest" ->  {s}
                [] /\ Sessions[s]["StateRegs"][1]["pc"][1] = "p_allocate"
                   /\ \/ e2 = "manager"  
                      \/ e2 = "guest" ->  {s} 
                \* from conf step
                [] /\ Sessions[s]["StateRegs"][1]["pc"][1] = "f_is_accepted"
                   /\ \/ e2 = "manager"  
                      \/ e2 = "guest" ->  {s} 
                [] OTHER -> {}]]
        /\ New2Old  = <<<<max>>, <<min>>>>
        /\ Ignore   = 0
        /\ XLocks   = Undef
        /\ VPol     =
           [
            conferences_name   |-> [ext |-> 0, policy |-> min, name |-> "conferences_name"],
            sections_section_id   |-> [ext |-> 0, policy |-> min, name |-> "sections_section_id"],
            \*CompInv fix
            submissions_conference_id   |-> [ext |-> 0, policy |-> max, name |-> "submissions_conference_id"],
            conferences_start_date   |-> [ext |-> 0, policy |-> min, name |-> "conferences_start_date"],
            \*CompInv fix
            papers_paper_id   |-> [ext |-> 0, policy |-> max, name |-> "papers_paper_id"],
            \*CompInv fix
            submissions_status   |-> [ext |-> 0, policy |-> max, name |-> "submissions_status"],
            conferences_description   |-> [ext |-> 0, policy |-> min, name |-> "conferences_description"],
            \*CompInv fix
            submissions_submission_id   |-> [ext |-> 0, policy |-> max, name |-> "submissions_submission_id"],
            \*CompInv fix
            papers_abstract   |-> [ext |-> 0, policy |-> max, name |-> "papers_abstract"],
            \*CompInv fix
            allocations_allocation_date   |-> [ext |-> 0, policy |-> max, name |-> "allocations_allocation_date"],
            \*CompInv fix
            submissions_paper_id   |-> [ext |-> 0, policy |-> max, name |-> "submissions_paper_id"],
            \*CompInv fix
            allocations_submission_id   |-> [ext |-> 0, policy |-> max, name |-> "allocations_submission_id"],
            sections_title   |-> [ext |-> 0, policy |-> min, name |-> "sections_title"],
            \*CompInv fix
            allocations_paper_id   |-> [ext |-> 0, policy |-> max, name |-> "allocations_paper_id"],
            \*CompInv fix
            papers_text   |-> [ext |-> 0, policy |-> max, name |-> "papers_text"],
            \*CompInv fix
            allocations_section_id   |-> [ext |-> 0, policy |-> max, name |-> "allocations_section_id"],
            \*CompInv fix
            logs_err_info   |-> [ext |-> 0, policy |-> max, name |-> "logs_err_info"],
            \*CompInv fix
            submissions_submission_date   |-> [ext |-> 0, policy |-> max, name |-> "submissions_submission_date"],
            \*CompInv fix
            papers_title   |-> [ext |-> 0, policy |-> max, name |-> "papers_title"],
            sections_conference_id   |-> [ext |-> 0, policy |-> min, name |-> "sections_conference_id"],
            \*CompInv fix
            papers_authors   |-> [ext |-> 0, policy |-> max, name |-> "papers_authors"],
            sections_start_date   |-> [ext |-> 0, policy |-> min, name |-> "sections_start_date"],
            sections_place   |-> [ext |-> 0, policy |-> min, name |-> "sections_place"],
            sections_end_date   |-> [ext |-> 0, policy |-> min, name |-> "sections_end_date"],
            \*CompInv fix
            logs_event_id   |-> [ext |-> 0, policy |-> max, name |-> "logs_event_id"],
            \*CompInv fix
            allocations_allocation_id   |-> [ext |-> 0, policy |-> max, name |-> "allocations_allocation_id"],
            conferences_conference_id   |-> [ext |-> 0, policy |-> min, name |-> "conferences_conference_id"],
            conferences_end_date   |-> [ext |-> 0, policy |-> min, name |-> "conferences_end_date"]           ]

Next ==
        \/  /\ XLocks = Undef
            /\ \E  s \in S :
               /\ Sessions[s]["StateRegs"] # <<>>
               /\ dispatch(s,Sessions[s]["StateRegs"])
        \/  \E  s \in S :
            /\ XLocks = s
            /\ dispatch(s,Sessions[s]["StateRegs"])
        \/  /\ XLocks = Undef
            /\ \A s \in S : Sessions[s]["StateRegs"] = <<>>
            /\ UNCHANGED vars

SpecFS == Init /\ [] [Next]_vars

=============================================================================