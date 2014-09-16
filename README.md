Horribly unfinished Ludum Dare 30 entry by suve.


Dependencies
--------------------
To compile, you'll need `SDL-devel`, `SDL_image-devel` and `mesa-libGL-devel`.
It may be possible to compile with a different `*-libGL-devel` package installed, but I have not tested that.


Building
--------------------
To build the executable, I recommend using Free Pascal Compiler.
FPC comes equipped with SDL wrappers, so you don't need to install any additional Pascal sources.

    $ cd src/
    $ fpc ld30.pas

That's all you need to do. If there any unsatisfied dependencies, you'll get an error while linking.


Running
--------------------
Just run the game from the main directory.

    $ ./ld30
