FROM ubuntu:14.04
RUN apt-get update
RUN apt-get install -y tclsh libtool autoconf build-essential flex bison gfortran pkg-config libexpat1 libexpat1-dev mpich2 libnetcdf-dev
ADD src /src
WORKDIR /src
RUN ./autogen.sh
RUN CFLAGS='-O2 -fPIC -m64' CXXFLAGS='-O2 -fPIC -m64' FFLAGS='-O2 -fPIC -m64' FCFLAGS='-O2 -fPIC -m64' ./configure --prefix=`pwd`
RUN make ds-install

RUN cp /src/bin/d_hydro.exe /src/d_hydro.exe
RUN ls /src/lib
ENV LD_LIBRARY_PATH=/src/lib:$LD_LIBRARY_PATH

RUN mkdir /job
VOLUME /job
WORKDIR /job
CMD /src/bin/deltares_hydro.tcl config_flow2d3d.ini