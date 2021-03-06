open OUnit2
open TodoList
open Command

let parse_test
    (name : string)
    (expected_output : Command.t)
    (input : string) =
  name >:: fun _ -> assert_equal expected_output (Command.parse input)

let assertion_sets_test (name : string) expected_exception input_command
    =
  name >:: fun _ ->
  assert_raises expected_exception (fun () ->
      Command.parse_settings input_command)

let assertion_test (name : string) expected_exception input_command =
  name >:: fun _ ->
  assert_raises expected_exception (fun () ->
      Command.parse input_command)

let get_phrase_test
    (name : string)
    (expected_output : string)
    (input : string) =
  name >:: fun _ ->
  assert_equal expected_output
    (input |> Command.parse |> Command.get_phrase)

let parse_add_tests =
  [
    parse_test "Add TEST 1: Parsing the add command"
      (Add ([ "Complete"; "CS"; "homework" ], Date.create_date "1/2"))
      "add Complete CS homework. 1/2";
    parse_test
      "Add TEST 2: Parsing the add command with spaces in the command"
      (Add ([ "Complete"; "CS"; "homework" ], Date.create_date "11/23"))
      "add             Complete        CS       homework .   \
       11/23      ";
  ]

let parse_edit_tests =
  [
    parse_test "Edit TEST 1: Parsing the edit command"
      (Edit ([ "Complete"; "CS"; "homework." ], Date.create_date "2/1"))
      "edit Complete CS homework. 2/1";
  ]

let parse_complete_tests =
  [
    parse_test "Complete TEST 1: Parsing the complete command"
      (Complete 1) "complete 1";
    parse_test
      "Command TEST 2: Parsing the complete command with spaces"
      (Complete 10) "              complete    10   ";
    ( "Command TEST 3: Parsing the complete command with invalid date"
    >:: fun _ ->
      assert_raises Malformed (fun () ->
          Command.parse "              complete    what   ") );
  ]

let parse_quit_test =
  [
    parse_test "Quit TEST 1: Parsing the quitcommand" Quit "quit";
    parse_test "Quit TEST 2: Parsing quit with a period" Quit "quit.";
  ]

let parse_clear_test =
  [
    parse_test "Clear TEST 1: Parsing the clear command" Clear "clear";
    parse_test "Clear TEST 2: Parsing the clear command" Clear "clear.";
  ]

let parse_settings_test =
  [
    parse_test "Settings TEST 1: Parsing regular settings command"
      Settings "settings";
    parse_test "Settings TEST 2: Parsing regular settings command"
      Settings "settings.";
  ]

let settings_cmd_test
    (name : string)
    (expected_sets_cmd : Command.setting_t)
    input_sets_cmd =
  name >:: fun _ ->
  assert_equal expected_sets_cmd (Command.parse_settings input_sets_cmd)

let show_complete_command_tests =
  [
    settings_cmd_test "Show Complete TEST 1: Testing turning things on"
      (Completed true) "show-complete on";
    settings_cmd_test
      "Show Complete  TEST 2: Testing turning things off"
      (Completed false) "show-complete off";
    settings_cmd_test
      "Show Complete  TEST 3: Testing turning things on with spaces"
      (Completed true) "      show-complete        on";
    settings_cmd_test
      "Show Complete  TEST 4: Testing turning things off with spaces"
      (Completed false) "      show-complete        off   ";
    assertion_sets_test
      "Show complete TEST 5: Testing with misspelled argument" Malformed
      "show-complete hello ";
    assertion_sets_test
      "Show complete TEST 6: Testing with misspelled keyword" Malformed
      "show complete on ";
    assertion_sets_test
      "Show complete TEST 7: Testing with misspelled both" Malformed
      "what is going on ";
    assertion_sets_test "Show complete TEST 7: Testing with empty space"
      Empty "     ";
  ]

let get_settings_attributes =
  [
    settings_cmd_test "Printer TEST 1: Testing normal parsing for week"
      (Printer Settings.Week) "printer Week";
    settings_cmd_test "Printer TEST 2: Testing week with spaces in btw"
      (Printer Settings.Week) "       printer     Week      ";
    settings_cmd_test
      "Printer TEST 3: Testing week that's misspelled  in btw"
      (Printer Settings.Week) "       printer     Week      ";
    assertion_sets_test
      "Printer TEST 4: Testing with misspelled printer" Malformed
      "printer week";
    assertion_sets_test
      "Printer TEST 5: Testing with misspelled printer and space in \
       between"
      Malformed "     printer        week     ";
    assertion_sets_test
      "Printer TEST 6: Testing with misspelled printer keyword between"
      Malformed "print Week";
    assertion_sets_test
      "Printer TEST 7: Testing with just the keyword itself" Malformed
      "printer";
    settings_cmd_test "Printer TEST 8: Testing normal parsing for week"
      (Printer Settings.Tasks) "printer Tasks";
    settings_cmd_test "Printer TEST 9: Testing week with spaces in btw"
      (Printer Settings.Tasks) "       printer     Tasks      ";
    settings_cmd_test
      "Printer TEST 10: Testing week that's misspelled  in btw"
      (Printer Settings.Tasks) "       printer     Tasks      ";
    assertion_sets_test
      "Printer TEST 11: Testing with misspelled printer" Malformed
      "printer tasks";
    assertion_sets_test
      "Printer TEST 12: Testing with misspelled printer and space in \
       between"
      Malformed "     printer        tasks     ";
    assertion_sets_test
      "Printer TEST 13: Testing with misspelled printer keyword between"
      Malformed "print Tasks";
    assertion_sets_test
      "Printer TEST 14: Testing with just the keyword itself" Malformed
      "printer";
  ]

let parsing_date_tests =
  [
    settings_cmd_test "Date_parse TEST 1: Testing valid date"
      (Date (Date.create_date "1/1"))
      "date 1/1";
    settings_cmd_test "Date_parse TEST 2: Testing another valid date"
      (Date (Date.create_date "12/11"))
      "date  12/11";
    settings_cmd_test
      "Date_parse TEST 3: Testing another valid date with spaces in \
       the phrase"
      (Date (Date.create_date "12/11"))
      "   date       12/11        ";
    settings_cmd_test "Date_parse TEST 4: Testing date with no date"
      (Date (Date.create_date ""))
      "   date         ";
  ]

let settings_help_test =
  [
    settings_cmd_test
      "settings help TEST 1: Testing getting settings help" SetsHelp
      "help";
  ]

let parse_exit_test =
  [
    settings_cmd_test "Exit TEST 1: Parsing the exit command" Exit
      "exit";
    settings_cmd_test
      "Exit TEST 2: Parsing the exit command with spaces" Exit
      "      exit       ";
    assertion_sets_test "Exit TEST 3: Testing with misspelled keyword"
      Malformed " exitt";
    assertion_sets_test "Exit TEST 4: Empty for exit" Empty "     ";
  ]

let assertion_sets_tests =
  [
    assertion_sets_test
      "Settings cmd assertion TEST 1: Just the word toggle will be \
       malformed"
      Malformed "show-complete";
    assertion_sets_test
      "Settings cmd assertion TEST 2: toggle with other phrases is \
       malformed"
      Malformed "show-complete hello";
    assertion_sets_test
      "Settings cmd assertion TEST 3: toggle with other phrases with \
       spaces is malformed"
      Malformed "     show-complete  what      is going    on";
    assertion_sets_test
      "Settings cmd assertion TEST 4: empty phrase raises empty" Empty
      "";
    assertion_sets_test
      "Settings cmd assertion TEST 5: spaces raise empty" Empty
      "         ";
    assertion_sets_test
      "Settings cmd assertion TEST 6: invalid date raises Invalid"
      Malformed "date 6/40";
    assertion_sets_test
      "Settings cmd assertion TEST 7: Incorrect format of date raises \
       Invalid"
      Malformed " date  1     /3      0      ";
  ]

let get_phrase_tests =
  [
    get_phrase_test
      "Get phrase TEST 1: Getting a valid input's phrase with a date"
      "finish my homework" "add finish my homework. 3/1";
    get_phrase_test
      "Get phrase TEST 2: Getting a valid input's phrase without a date"
      "finish my homework" "add finish my homework.";
    get_phrase_test
      "Get phrase TEST 3: Getting a valid input's phrase with spaces"
      "finish my homework" "add        finish   my       homework.";
    get_phrase_test
      "Get phrase TEST 4: Getting a valid input's phrase with spaces \
       and a date"
      "finish my homework"
      "add        finish   my       homework.      3/2";
  ]

let assertion_tests =
  [
    assertion_test
      "Assertion TEST 1: Assert Command raises Malformed for wrong verb"
      Malformed "finish my homework please";
    assertion_test
      "Assertion TEST 2: Assert Command raises Empty for an empty \
       command"
      Empty "";
    assertion_test
      "Assertion TEST 3: Assert Command raises Empty for command with \
       spaces"
      Empty "                     ";
    assertion_test
      "Assertion TEST 4: Assert quit raises Malformed for including \
       extra things"
      Malformed "quit hello yes";
    assertion_test
      "Assertion TEST 5: Assert add raises Empty for not including any \
       phrase"
      Empty "add";
    assertion_test
      "Assertion TEST 6: Assert add raises Empty for not including any \
       phrase with a period"
      Empty "add .";
    ( "Assertion TEST 7: Assert get phrase raises Invalid for using \
       complete"
    >:: fun _ ->
      assert_raises Invalid (fun () ->
          "complete 10" |> Command.parse |> Command.get_phrase) );
    ( "Assertion TEST 8: Assert get phrase raises Invalid for using quit"
    >:: fun _ ->
      assert_raises Invalid (fun () ->
          "quit" |> Command.parse |> Command.get_phrase) );
    ( "Assertion TEST 9: Assert get phrase raises Invalid for clear"
    >:: fun _ ->
      assert_raises Invalid (fun () ->
          "clear" |> Command.parse |> Command.get_phrase) );
    assertion_test
      "Assertion TEST 10: Assert raises Malformed for clear with extra \
       stuff"
      Malformed "clear stuff";
  ]

let suite =
  List.flatten
    [
      parse_add_tests;
      parse_complete_tests;
      parse_quit_test;
      get_phrase_tests;
      parse_settings_test;
      assertion_tests;
      show_complete_command_tests;
      assertion_sets_tests;
      parsing_date_tests;
      parse_exit_test;
      get_settings_attributes;
    ]