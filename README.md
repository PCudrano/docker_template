# Docker template
This is a template to set up a docker image on the **AIRLab servers**, preserving your user and group IDs to access all resources within the AIRLab cluster.

## Setup
Clone this repo for each new docker image you need to set up. (Remember to keep each copy in order to restore your image in the future.)

The prepared `Dockerfile` sets up an image based on Ubuntu 20.04 with CUDA 11.7.1, python 3.9, and all the setups required for running notebooks and using weights&Biases or Neptune.

You can customize your image installing additional `apt` and `pip` packages.<br>
To install additional `apt` packages, add them to the `apt_requirements.txt` file.<br>
To install additional `pip` packages, add them to the `requirements.txt` file.

To build your image, run in this folder:
```
./build.sh -- -t <image_name> .
```
where, as per lab's rules, `<image_name>` must be in the form `<username>/<name>:<tag>` (e.g., for user Mario Rossi: `rossi/pytorch:full`).

### Additional options
You can specify additional options using the full build command:
```
./build.sh -p <path/to/pip_requirements_file.txt>
           -a <path/to/apt_requirements_file.txt>
           -- <docker build args>
```
where `<docker build args>` is the complete set of arguments you would normally pass to `docker build` (including for example `-t <image name>` and `path/to/Dockerfile`).

##### Full specs
```
Usage: build [-h | --help]
       build [ -p | --pip-req ] [ -a | --apt-req ] -- <docker build args>
Options:
   -h | --help          show this help text
   -p | --pip-req       specify the path of the pip requirements.txt file
   -a | --apt-req       specify the path of the apt requirements file
```


## Edit & extend
Feel free to extend this repo and add new functionalities to the template!
You can open a pull request to have your changes integrated.<br>
For this purpose, please mind that the repo has the following structure:
```
.
├── apt_requirements.txt    # (USER CAN CUSTOMIZE) Packages to be installed via apt
├── requirements.txt        # (USER CAN CUSTOMIZE) Packages to be installed via pip (standard `requirements.txt` file)
├── Dockerfile              # Sets up the docker image, creates the required user and groups, and installs the specified apt and pip packages
└── build.sh                # Main script - Calls `docker build` with the correct arguments (see above for options)
```
