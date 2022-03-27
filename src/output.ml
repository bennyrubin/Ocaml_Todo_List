(* art from https://www.asciiart.eu/animals/camels and
   https://patorjk.com/software/taag/#p=display&f=Standard&t=OCaml%20TodoList *)

(* End of file should exit gracefully*)

let ascii_art =
  {|
                ,,__
      ..  ..   / o._)    ___   ____                _   _____         _       _     _     _                  
      /--'/--\  \-'||   / _ \ / ___|__ _ _ __ ___ | | |_   _|__   __| | ___ | |   (_)___| |_     
    /        \_/ / |   | | | | |   / _` | '_ ` _ \| |   | |/ _ \ / _` |/ _ \| |   | / __| __|                      
  .'\  \__\  __.'.'    | |_| | |__| (_| | | | | | | |   | | (_) | (_| | (_) | |___| \__ \ |_  
    )\ |  )\ |          \___/ \____\__,_|_| |_| |_|_|   |_|\___/ \__,_|\___/|_____|_|___/\__|
    // \\ // \\
  ||_  \\|_  \\_
  '--' '--'' '--'
|}

(*Print them in the following way, where i is number of task i. <Name of
  Task> -- [<due date>] - <due date - current date> days remaining
  ... *)

(*helper function to go from string list * string list to string *
  string list*)
let pack_string_list l1 l2 = List.map2 (fun x y -> (x, y)) l1 l2
let no_date_format = "%d. %s"
let date_format = "%d. %s [%s] - <> days remaining"

let unpack_some = function
  | Some x -> x
  | None -> failwith "Cannot be none"

(* helper function to format a single task into the right output*)
let format_task tasks i =
  (*to display starting at 1*)
  (*TODO: factor this out into different functions based on complete or
    date*)
  let name = Tasks.task_name tasks i in
  let date_opt = Tasks.task_date_opt tasks i in
  let complete = Tasks.completed tasks i in
  let print_i = i + 1 in
  let star = if complete then "( * )" else "(   )" in
  let mods = ref (if complete then [ ANSITerminal.Bold ] else []) in
  let output =
    if date_opt = None then
      Printf.sprintf "%s   %d. %s" star print_i name
    else
      let date_str = Tasks.task_date_str tasks i in
      let days_left = Date.days_remaining (unpack_some date_opt) in
      if days_left < 0 then
        let () =
          if complete then () else mods := ANSITerminal.red :: !mods
        in
        Printf.sprintf "%s   %d. %s [%s] - OVERDUE" star print_i name
          date_str
      else
        Printf.sprintf "%s   %d. %s [%s] - <%d> days remaining" star
          print_i name date_str days_left
  in
  (output, complete, !mods)

let print_ascii_art () =
  ANSITerminal.print_string [ ANSITerminal.yellow ] ascii_art

(* Helper function to get a range list*)
let rec range i j = if i > j then [] else i :: range (i + 1) j

let print_tasks st =
  let open ANSITerminal in
  let tasks = State.get_tasks st in
  let length = Tasks.tasks_amount tasks in
  let formatted_tasks =
    List.map (format_task tasks) (range 0 (length - 1))
  in
  erase Screen;
  set_cursor 1 1;
  print_ascii_art ();
  List.iter
    (fun (str, com, mods) -> print_string mods (str ^ "\n"))
    formatted_tasks;
  print_endline "\n\n\n\n\n";
  set_cursor 1 100

let input () = print_string "> "
let quit () = print_endline "Quitting..."
let empty () = print_endline "Empty input. Please re-enter valid entry."

let malformed () =
  print_endline "Malformed input. Please re-enter valid entry."

let help () =
  print_endline
    "Ocaml_Todo_List is a terminal-based productivity application that \
     utilizes ASCII art to display your goals in a pretty and fun way: \n\
     * To add a task to your todo list type the following in the \
     command line: “add [task_name]. (optional) [date]”. Note: the \
     period is required. \n\
     * To mark a task completed, type “complete [index]”\n\
     * To clear the list, type 'clear'\n\
     * To leave the todo list, type: “quit”."
