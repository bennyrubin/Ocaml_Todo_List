open Yojson.Basic.Util
open Date

exception InvalidDate of (int * int)
exception ElementOutofBounds of int

type t = {
  display_completed : bool;
  due_before : Date.t option;
}
(* unimplemented color_palate : Color *)

let setting_of_json json =
  {
    display_completed = json |> member "display_completed" |> to_bool;
    due_before =
      json |> member "due_before" |> Yojson.Basic.to_string
      |> create_date;
  }

let from_file file = Yojson.Basic.from_file file |> setting_of_json

let format tsk =
  let { display_completed; due_before } = tsk in
  `Assoc
    [
      ("display_completed", `Bool display_completed);
      ( "due_before",
        match due_before with
        | None -> `String ""
        | Some date -> `String (Date.to_string date) );
    ]

let to_file file sets = Yojson.Basic.to_file file (format sets)
let rec settings sets = [ "display_completed"; "due_before" ]
let setting sets n = List.nth (settings sets) n

let set_display_completed sets b =
  { display_completed = b; due_before = sets.due_before }

let set_due_before sets d =
  { display_completed = sets.display_completed; due_before = d }
