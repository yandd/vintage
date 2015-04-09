////////////

A recorded demo video can be found in Snapshots folder.

~/Instant Messaging run instructions (a simple chatting C/S demo)
after running chat server in DrScheme 4.2.1
type in command line:
> (run-server 'd)

Then, after running chat clients in DrScheme 4.2.1, 
type in command line:
> (run-clients 'd)

Message format:

> Reciepint_name: msg

e.g.

// sending msg to XF
> XF: msg1

// broadcasting msg all active clients
> *: msg     
