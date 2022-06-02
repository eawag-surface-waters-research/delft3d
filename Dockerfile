FROM ubuntu:14.04
RUN apt-get update
RUN apt-get install -y tclsh libtool autoconf build-essential flex bison gfortran pkg-config libexpat1 libexpat1-dev mpich2 libnetcdf-dev
ADD delft3d /delft3d
WORKDIR /delft3d/5.01.00.2163/src
RUN ./autogen.sh
RUN CFLAGS='-O2 -fPIC -m64' CXXFLAGS='-O2 -fPIC -m64' FFLAGS='-O2 -fPIC -m64' FCFLAGS='-O2 -fPIC -m64' ./configure --prefix=`pwd`
RUN make ds-install

RUN cp /delft3d/5.01.00.2163/src/bin/d_hydro.exe /delft3d/5.01.00.2163/src/d_hydro.exe
RUN ls /delft3d/5.01.00.2163/src/lib
ENV LD_LIBRARY_PATH=/delft3d/5.01.00.2163/src/lib:$LD_LIBRARY_PATH

RUN mkdir /job
VOLUME /job
WORKDIR /job
CMD /delft3d/5.01.00.2163/src/bin/deltares_hydro.tcl config_flow2d3d.ini