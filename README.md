# Mojolicious::Command::Pump

A command that pumps embedded files into and out of your Mojolicious::Lite app.

## Put me in `@INC`

As long as I'm in `@INC`, you don't have to change your app:

    $ export PERL5LIB=Mojolicious-Command-Pump/lib/:$PERL5LIB
    $ mojo generate lite_app demo

## List the embedded files in your app 

Running commands against your app will tell you what's in it:

    $ ./bin/demo pump list
    >> 402528 bytes of perl <<
    @@ (preamble)                                              58 bytes
    @@ index.html.ep                                           195 bytes
    @@ layouts/default.html.ep                                 104 bytes

unless it's a full-fat Mojo app:

    ./script/non-lite-app pump list
    >> 0 bytes of perl <<
    @@ (preamble)                                              0 bytes

## Add resources to your app

You can add base64'ed images to your lite app:

    $ wget http://example.com/cute-kitten.jpg
    #   -b base64s the file
    #   -i in-place edits your app (the default is to print the new version)
    $ ./bin/demo pump add -i -b  cute-kitten.jpg
    Adding cute-kitten.jpg base64

    $ ./bin/demo pump list
    >> 123675 bytes of perl <<
    @@ (preamble)                                              58 bytes
    @@ index.html.ep                                           195 bytes
    @@ layouts/default.html.ep                                 104 bytes
    @@ cute-kitten.jpg                                         123071 bytes

    $ bin/demo get /cute-kitten.jpg |wc
        286    2517   91102    
    # You can get it out this way, and dump it in a file
    $ bin/demo get /cute-kitten.jpg > ~/kittens-from-my-app.jpg
    
    $ hypnotoad bin/demo
    [Tue May 23 23:49:07 2017] [info] Listening at "http://*:8080"
    Server available at http://127.0.0.1:8080
    $ Open http://127.0.0.1:8080/cute-kitten.jpg
    <Safari with kitten>

## You can remove items from your app 

You can remove stuff from your lite app:

    $ ./bin/demo pump rm -i cute-kitten.jpg
    cute-kitten.jpg, matches: cute-kitten.jpg so I removed it.

    $ ./bin/demo pump list
    >> 604 bytes of perl <<
    @@ (preamble)                                              58 bytes
    @@ index.html.ep                                           195 bytes
    @@ layouts/default.html.ep                                 104 bytes
    
# Future features

  * recursive addition/removal of paths, maybe with globs
  * ... `pump mv OLD NEW` - rename files inlined in the app.
  * ... `pump inflate` - inflate all the inline resource in a way similar to Mojolicious::Commands::inflate 
  * ... `pump deflate` - put them back again
  * ... `pump status` - notice if resources on disk differ from those in the app.
  * better behaviour for updating existing files - currently add always appends 

