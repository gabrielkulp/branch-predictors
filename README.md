# Branch Predictor Comparison

A grad school class project using gem5 to compare the performance of various branch predictors.

## How to build

Dependencies: Just `git` and `docker`!

Simply run `./build.sh` to build a (rather large) development image.
This long build time (15-30 minutes) only needs to happen once, and later builds will be *much* faster.
This produces an image called `gem5-dev` that you can run `run.sh` as described below.

If you want to start a shell inside the container to investigate after a build, run `docker run --rm -it gem5-dev:RISCV bash`.
You probably won't need to do this often.

If you want to use a different architecture, run `./build.sh -a ARM` or `./build.sh -a X86`.
Then use that architecture after the colon in the `docker run` command above.
Building for different architectures *will not* overwrite each other.

## How to run

After building, use `run.sh` to automatically handle making input files available to the container and output files available to the host.
Use the script name and container name in place of `gem5`, so `gem5 --help` becomes `./run.sh gem5-dev:RISCV --help`.
Here's an example command:

```
./run.sh gem5-dev:RISCV configs/learning_gem5/part1/simple.py
```

Results and statistics from a run are stored in `./m5out` in your current directory.

The current directory when you run `./gem5.sh` is mounted into `/opt` inside the container, so you must use relative paths for files.
(Specify the config file with a path that does not start with `/`.)

This repo contains `tests` and `configs` directories that were originally copied from [gem5 v20.2.0.0](https://gem5.googlesource.com/public/gem5/+/refs/tags/v21.2.0.0/).
They are required to run the above example command.

## How to contribute

The contents of the `gem5` directory is copied into the gem5 repository inside the container before starting the second incremental build.
This means that any files or directories you add or change inside there will be additions or changes to the full gem5 source code.

After making a change, just run `./build.sh` again and the image will rebuild to reflect that change.
The most recent build for some architecture (ARCH) is always what you get when you use the `gem5-dev:ARCH` image.

## Making and using a smaller image

The `gem5-dev:*` images are large (at least 5GB) because they include many development-specific packages that are not needed at runtime.
They also contain many `*.o` files and other intermediates that are helpful in speeding up later builds, but are not used at runtime.

To export an image that does not include these things, run `./build.sh -x`.
This produces a (much) smaller `gem5:*` image rather than a `gem5-dev:*` image.
As always, you can specify ARM or X86 with the `-a` flag.

You can also download a precompiled image with `docker pull gabrielkulp/gem5:RISCV`, `:ARM`, or `:X86`.
You can upload your own with `./build.sh -u USER`, where `USER` is your Dockerhub username.
