port module Ports exposing (openAlert)


port openAlert : String -> Cmd msg

-- port closeAlert : String -> Cmd msg

port toggleAlertDetails : String -> Cmd msg
