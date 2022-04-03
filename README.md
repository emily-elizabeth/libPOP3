# libPOP3
 POP3 library for LiveCode

## Commands
POP3Connect server, isSecure, callbackTarget  
POP3Disconnect server  
POP3MessageCount server  
POP3MessageList server  
POP3NOOP server  
POP3DeleteMessage server, messageNumber  
POP3RetrieveMessage server, messageNumber  
POP3SendUsername server, username  

## Callbacks
POP3Connected server  
POP3MessageDeleted server, messageNumber  
POP3MessageListReceived server, messageList  
POP3NOOPSuccessful server  
POP3LoggedIn server  
POP3Disconnected server
POP3MessageRetrieved server, message  
POP3MessageCountReceived server, messageCount  
POP3UsernameRequested(server)  
POP3PasswordRequested(server)
