////////////

A recorded demo video can be found in Snapshots folder.

~/Instant Messaging run instructions (a simple chatting C/S demo)
1. Server part
after running chat server source code in DrScheme 4.2.1
type in command line:
> (run-server 'd)

2. Client part
After running chat client source code in DrScheme 4.2.1, use command line provided to generate clients.

As a quick example, type in command line, 4 pre-coded clients will register with LOCALHOST:
> (run-clients 'd)

Alternatively, to run a single client:
> (run-client "ClientName")

This program works under LAN as well. User may need to manually change the server IP parameter 
(at the bottom of the chat client source code, i.e. change LOCALHOST to "192.168.0.1"). 

Message format in chat window:

> Reciepint_name: msg

e.g.

// sending msg to XF
> XF: msg1

// broadcasting msg all active clients
> *: msg     
