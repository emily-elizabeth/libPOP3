script "libPOP3"
local currentCommand
local callbackTargets



-- Connect to the server
-- server is a fully qualified pointer to a socket (example.com:110|libPOP3)
-- isSecure is a boolean whether to use a secure connection or not
-- callbackTarget is the long id of the object that will handle callbacks from the library
--
on POP3Connect server, isSecure, callbackTarget
   if (server is among the lines of the openSockets) then throw "POP3: Connection already opened. (" & server & ")"
   put "CONN" into currentCommand[server]
   put callbackTarget into callbackTargets[server]
   if (isSecure) then
      open secure socket to server with message "_POP3Read"
   else open socket to server with message "_POP3Read"
   if (the result is not EMPTY) then
      throw "POP3: Could not open connection. (" & server & ")"
   end if
end POP3Connect



-- Disconnect from the server
-- server is a fully qualified pointer to a socket (example.com:110|libPOP3)
--
on POP3Disconnect server
   if (server is among the lines of the openSockets) then  // only do this if connected
      _POP3Write server, "QUIT"
   else
      dispatch "POP3Disconnected" to callbackTargets[server] with server
   end if
end POP3Disconnect



-- Request the number of messages on the server
-- server is a fully qualified pointer to a socket (example.com:110|libPOP3)
--
on POP3MessageCount server
   _POP3Write server, "STAT"
end POP3MessageCount



-- Request the list of messages on the server
-- server is a fully qualified pointer to a socket (example.com:110|libPOP3)
--
on POP3MessageList server
   _POP3Write server, "LIST"
end POP3MessageList



-- Request to have a message marked for deletion
-- server is a fully qualified pointer to a socket (example.com:110|libPOP3)
-- messageNumber is the number of the message you want to mark for deletion
--
on POP3DeleteMessage server, messageNumber
   _POP3Write server, "DELE" && messageNumber
end POP3DeleteMessage



-- Request to retrieve the message from the server
-- server is a fully qualified pointer to a socket (example.com:110|libPOP3)
-- messageNumber is the number of the message you want to retrieve
--
on POP3RetrieveMessage server, messageNumber
   _POP3Write server, "RETR" && messageNumber
end POP3RetrieveMessage



---- PRIVATE METHODS -----


-- Reads a line of data from the server
--
on _POP3Read server
   if (server is among the lines of the openSockets) then
      read from socket server until CRLF with message "_POP3DataAvailable"
   else
      throw "POP3: Connection is closed. (" & server & ")"
   end if
end _POP3Read



-- Writes a command to the server
--
on _POP3Write server, data
   if (server is among the lines of the openSockets) then
      put word 1 of data into currentCommand[server]  // store the current command for processing the read data
      write data & CRLF to socket server with message "_POP3Read"
   else
      throw "POP3: Connection is closed. (" & server & ")"
   end if
end _POP3Write



-- Processes the data read from the server
--
on _POP3DataAvailable server, data
   if (char 1 of data = "+") then  // everything was okay, so let's see what we need to do with the data
      switch currentCommand[server]
         case "CONN"
            dispatch "POP3Connected" to callbackTargets[server] with server
            dispatch function "POP3UsernameRequested" to callbackTargets[server] with server
            _POP3Write server, "USER" && the result
            break
         case "DELE"
            dispatch "POP3MessageDeleted" to callbackTargets[server] with server, word 2 of currentCommand[server]
            break
         case "LIST"
            read from socket server until CRLF & "." & CRLF  with message "_POP3MessageListReceived"
            //dispatch "POP3MessageListReceived" to callbackTargets[server] with server, buffer[server]
            break
         case "PASS"
            dispatch "POP3LoggedIn" to callbackTargets[server] with server
            break
         case "QUIT"
            dispatch "POP3Disconnected" to callbackTargets[server] with server
            break
         case "RETR"
            read from socket server until CRLF & "." & CRLF with message "_POP3MessageRetrieved"
            //dispatch "POP3MessageRetrieved" to callbackTargets[server] with server, buffer[server]
            break
         case "STAT"
            dispatch "POP3MessageCountReceived" to callbackTargets[server] with server, word 2 of data
            break
         case "USER"
            dispatch function "POP3PasswordRequested" to callbackTargets[server] with server
            _POP3Write server, "PASS" && the result
            break
      end switch
   else if (char 1 of data = "-") then  // we encountered an error
   end if
end _POP3DataAvailable



on _POP3MessageRetrieved server, data
   dispatch "POP3MessageRetrieved" to callbackTargets[server] with server, data
end _POP3MessageRetrieved


on _POP3MessageListReceived server, data
   dispatch "POP3MessageListReceived" to callbackTargets[server] with server, data
end _POP3MessageListReceived
