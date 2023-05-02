#
# Build an Ubuntu installation of gmsvtoolkit
#
from ubuntu:jammy
MAINTAINER Philip Maechling maechlin@usc.edu

# Define Build and runtime arguments
# These accept userid and groupid from the command line
#ARG APP_UNAME
#ARG APP_GRPNAME
#ARG APP_UID
#ARG APP_GID
#ARG BDATE

ENV APP_UNAME=scecuser \
APP_GRPNAME=scec \
APP_UID=1000 \
APP_GID=20 \
BDATE=20230428

# Retrieve the userid and groupid from the args so 
# Define these parameters to support building and deploying on EC2 so user is not root
# and for building the model and adding the correct date into the label
RUN echo $APP_UNAME $APP_GRPNAME $APP_UID $APP_GID $BDATE

#
RUN apt-get -y update
RUN apt-get -y upgrade
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get install -y build-essential git vim nano python3 python3-pip jupyter

# Install latest gfortran and fftw
RUN apt-get install -y libfftw3-dev libfftw3-mpi-dev libopenmpi-dev gfortran
RUN pip3 install matplotlib pandas jupyterlab

RUN ln -s /usr/bin/python3 /usr/bin/python

# Setup Owners
# Group add duplicates "staff" so just continue if it doesn't work
RUN groupadd -f --non-unique --gid $APP_GID $APP_GRPNAME
RUN useradd -ms /bin/bash -G $APP_GRPNAME --uid $APP_UID $APP_UNAME

#Define interactive user
USER $APP_UNAME

# Get a copy of the gmsvtoolkit_tutorials repo
WORKDIR /home/$APP_UNAME
RUN git clone https://github.com/SCECcode/gmsvtoolkit_tutorials.git

# Move to the user directory where the gmsvtoolkit is installed and built
WORKDIR /home/$APP_UNAME
RUN git clone https://github.com/SCECcode/gmsvtoolkit.git

WORKDIR /home/$APP_UNAME/gmsvtoolkit/gmsvtoolkit/src
RUN make -f makefile

# Setup GMSVtoolkit path
ENV PYTHONPATH="$PYTHONPATH:/home/$APP_UNAME/gmsvtoolkit/gmsvtoolkit"
ENV PATH="$PATH:/home/$APP_UNAME/gmsvtoolkit/gmsvtoolkit/src/gp/bin:/home/$APP_UNAME/gmsvtoolkit/gmsvtoolkit/src/ucb/bin:/home/$APP_UNAME/gmsvtoolkit/gmsvtoolkit/src/usgs/bin"
ENV GMSVTOOLKIT_DIR="/home/$APP_UNAME/gmsvtoolkit/gmsvtoolkit"


# Define file input/output mounted disk
#
VOLUME /home/$APP_UNAME/target
WORKDIR /home/$APP_UNAME/target
#
# The .bashrc and .bash_profile will Define ENV variables
#
#
# Add metadata to dockerfile using labels
LABEL "org.scec.project"="GMSVToolkit"
LABEL org.scec.responsible_person="Fabio Silva"
LABEL org.scec.primary_contact="fsilva@usc.edu"
LABEL version="$BDATE"


#Create interactive entry point
#ENTRYPOINT ["/usr/bin/jupyter","notebook","--ip=0.0.0.0","--notebook-dir=/home/scecuser/gmsvtoolkit_tutorials/notebooks","--allow-root","--no-browser"]
#CMD ["/bin/bash"]
