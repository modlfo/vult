(*
The MIT License (MIT)

Copyright (c) 2014 Leonardo Laguna Ruiz, Carl Jönsson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)

type identifier = string list
   [@@deriving show,eq,ord]

type property =
   | SimpleBinding (* Used by Passes.bindFunctionCalls to mark the function calls that have been bound *)
   | ActiveFunction
   | JoinFunction
   [@@deriving show,eq,ord]

type properties = property list
   [@@deriving show,eq,ord]

type attr =
   {
      loc   : Loc.t;
      props : properties;
   }
   [@@deriving show,eq,ord]

type type_exp =
   | TUnit      of attr
   | TId        of identifier    * attr
   | TTuple     of type_exp list * attr
   | TComposed  of identifier    * type_exp list * attr
   | TSignature of type_exp list * attr
   [@@deriving show,eq,ord]

type typed_id =
   | SimpleId of identifier * attr
   | TypedId  of identifier * type_exp * attr
   [@@deriving show,eq,ord]

type lhs_exp =
   | LWild  of attr
   | LId    of identifier   * attr
   | LTuple of lhs_exp list * attr
   | LTyped of lhs_exp * type_exp * attr
   [@@deriving show,eq,ord]

(** Parser syntax tree *)
type exp =
   | PUnit
      of attr
   | PBool
      of bool
      *  attr
   | PInt
      of int
      *  attr
   | PReal
      of float
      *  attr
   | PId
      of identifier  (* name *)
      *  attr
   | PUnOp
      of string      (* operator *)
      *  exp
      *  attr
   | PBinOp
      of string      (* operator *)
      *  exp
      *  exp
      *  attr
   | PCall
      of identifier option (* name/instance *)
      *  identifier        (* type/function name *)
      *  exp list          (* arguments *)
      *  attr
   | PIf
      of exp (* condition *)
      *  exp (* then *)
      *  exp (* else *)
      *  attr
   | PGroup
      of exp
      *  attr
   | PTuple
      of exp list
      *  attr
   | PSeq
      of identifier option (* Scope name *)
      *  stmt list
      *  attr
   | PEmpty
   [@@deriving show,eq,ord]
and stmt =
   | StmtVal
      of lhs_exp     (* names/lhs *)
      *  exp option  (* rhs *)
      *  attr
   | StmtMem
      of lhs_exp     (* names/lhs *)
      *  exp option  (* initial value *)
      *  exp option  (* rhs *)
      *  attr
   | StmtTable
      of identifier  (* name *)
      *  exp list    (* data *)
      *  attr
   | StmtWhile
      of exp         (* condition*)
      *  stmt        (* statements *)
      *  attr
   | StmtReturn
      of exp
      *  attr
   | StmtIf
      of exp         (* condition *)
      *  stmt        (* then *)
      *  stmt option (* else *)
      *  attr
   | StmtFun
      of identifier       (* name *)
      *  typed_id list    (* arguments *)
      *  stmt             (* body *)
      *  type_exp option  (* return type *)
      *  attr
   | StmtBind
      of lhs_exp     (* lhs *)
      *  exp         (* rhs *)
      *  attr
   | StmtBlock
      of identifier option (* scope name *)
      *  stmt list
      *  attr
   | StmtType
      of identifier           (* name *)
      *  typed_id list        (* arguments *)
      *  val_decl list        (* members *)
      *  attr
   | StmtAliasType
      of identifier           (* name *)
      *  typed_id list        (* arguments *)
      *  type_exp             (* alias type *)
      *  attr
   | StmtEmpty
   [@@deriving show,eq,ord]

and val_decl =
   identifier  (* name *)
   * type_exp  (* type *)
   * attr
   [@@deriving show,eq,ord]

type exp_list = exp list
   [@@deriving show,eq,ord]

type scope_kind =
   | FuncScope
   | LocalScope

type parser_results =
   {
      presult : (stmt list,Error.t list) CCError.t;
      file    : string;
      lines   : string array;
   }

type interpreter_results =
   {
      iresult : (string,Error.t list) CCError.t;
      lines   : string array;
   }

(** Stores the options passed to the command line *)
type arguments =
   {
      mutable files  : string list;
      mutable dparse : bool;
      mutable rundyn : bool;
      mutable debug  : bool;
      mutable ccode  : bool;
      mutable jscode : bool;
      mutable run_check  : bool;
      mutable output : string;
      mutable real   : string;
   }

let default_arguments =
   {
      files = ["live.vult"];
      dparse = false;
      rundyn = false;
      debug = false;
      ccode = false;
      jscode = true;
      run_check = false;
      output = "live";
      real = "float";
   }

let makeAttr (loc:Loc.t) : attr =
   { loc = loc; props = [] }