function make_quickplot(basedir)
%MAKE_QUICKPLOT Compile QUICKPLOT executable
%   Compile MATLAB code to QUICKPLOT executable
%
%   MAKE_QUICKPLOT(BASEDIR)
%   Use specified directory instead of current directory as base directory

%   $Id: make_quickplot.m 1714 2012-07-23 13:57:14Z jagers $

curdir=pwd;
addpath(curdir)
if matlabversionnumber<7.09
    error('Invalid MATLAB version. Use MATLAB R2009b (7.9) or higher for compiling Delft3D-QUICKPLOT!')
end
if ~exist('mcc')
    error('Cannot find MATLAB compiler. Use another MATLAB installation!')
end
if nargin>0
    curd=pwd;
    cd(basedir);
end
try
    err=localfunc;
catch
    err=lasterr;
end
if nargin>0
    cd(curd);
end
rmpath(curdir)
if ~isempty(err)
    error(err)
end


function err=localfunc
err='';
if ~exist('progsrc','dir')
    err='Cannot locate source'; return
end
sourcedir=[pwd,filesep,'progsrc'];
disp('Copying files ...')
if ~exist([pwd,filesep,'quickplot'])
    [success,message] = mkdir('quickplot');
    if ~success,
        err=message;
        return
    end
end
cd('quickplot');
diary make_quickplot_diary
if isunix
    unix('cp -rf ../progsrc/* .');
    unix('mv compileonly/* .');
else
    [s,msg]=dos('xcopy "..\progsrc\*.*" "." /E /Y');
    if s==0
        [s,msg]=dos('move compileonly\*.*  .');
    end
    if s~=0
        error(msg)
    end
end
%
copyfile('../../../../third_party_open/netcdf/matlab/netcdfAll-4.1.jar','.')
addpath ../../../../third_party_open/netcdf/matlab/mexnc
addpath ../../../../third_party_open/netcdf/matlab/snctools
%
qpversion=read_identification(sourcedir,'d3d_qp.m');
fprintf('\nBuilding Delft3D-QUICKPLOT version %s\n\n',qpversion);
TStr = datestr(now);
fstrrep('d3d_qp.m','<VERSION>',qpversion)
fstrrep('d3d_qp.m','<CREATIONDATE>',TStr)
fstrrep('wl_identification.c','<VERSION>',qpversion)
fstrrep('wl_identification.c','<CREATIONDATE>',TStr)
make_exe
X={'*.asv'
    '*.bak'
    '*.m'
    '*.c'
    '*.cpp'
    '*.h'
    '*.o'
    '*.obj'
    '*.a'
    '*.lib'
    '*.scc'
    'private'
    'compileonly'
    '@qp_data'
    '@qp_data_resource'};
if isunix
    X=cat(1,X,{'*.dll'
        '*.mexw*'});
else
    X=cat(1,X,{'*.mexglx'
        '*.mexa64'
        '*.exp'});
end
cleanup(X)
diary off
cd ..