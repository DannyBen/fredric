Testing
==================================================

Run tests with:

    $ run spec

To run a single spec file only, run something like:

    $ run spec api

Some tests require the FRED APi Key. Make sure to set your API Key
in the environment variable before running:

    $ export FREDRIC_KEY=y0urAP1k3y
    $ run spec


Testing on CI
--------------------------------------------------

When testing on Travis or Circle, be sure to also set the FREDRIC_KEY
environment variable.
