# vintage
Some old projects coded in scheme, back in 2009. Topics courtesy of CS course: Program Design Paradigm.
Special thanks to my teammates then: Liang, Kinjal, Ketan.

All programs are under 'as is' condition. 


PLT-Scheme(now Racket) v4.2.1 may be required to run. 
Download link is here: 
http://download.plt-scheme.org/drscheme/v4.2.1.html

///////
~/UFO run instructions:
after running in DrScheme 4.2.1, 
type in command line:
> (main INIT-SIS)

press space to launch missiles.

////////////
~/Instant Messaging run instructions (a simple chatting C/S demo)
after running chat server in DrScheme 4.2.1, 
type in command line:
> (run-server 'd)

Then, after running chat clients in DrScheme 4.2.1, 
type in command line:
> (run-clients 'd)

Message format:

Reciepint_name: msg

e.g.

XF: msg1
*:msg     // broadcasting to all active clients

/////////