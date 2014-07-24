function startMonkeyLogic(varargin)

% July 2104
% MAC

if nargin < 1
    % if user has launched matalb with java, use the version of ML
    % compatiable with java from May 2014. Otherwise, use previous version
    % from August 2013
    if  usejava('jvm')
        ML_ver = 'May2014';
    else
        ML_ver = 'Nov2013';
    end
elseif nargin == 1
    ML_ver = varargin{1};
end

% check that matlab has been launched as admin
if ~isWindowsAdmin
    error('Must run MATLAB as administrator for DAQ. Quit MATLAB and re-run as administrator.')
end

% remove any prexisting MonkeyLogic folders from search path
splitPath = regexp(path,'C:','split');
for folderIDX = 1:size(splitPath, 2)
    if ~isempty(findstr(splitPath{folderIDX}, 'MonkeyLogic'))
        rmpath(strcat('C:',splitPath{folderIDX}));
    end
end

% get current directory which should contain ML versions and Tasks
ML_folder = pwd;

% put monkeylogi on path
addpath(genpath(sprintf('%s\\MonkeyLogic_%s',ML_folder,ML_ver)));

% force monkeylogic to reset runtime, task, and home directories
if ispref('MonkeyLogic')
    rmpref('MonkeyLogic');
    set_ml_directories(ML_folder);
end


monkeylogic


function success = set_ml_directories(varargin)

success = 0;
d = which('monkeylogic');
if isempty(d),
    pname = uigetdir(pwd, 'Please indicate the location of the MonkeyLogic files...');
    if pname(1) == 0,
        return
    end
    addpath(pname);
else
    pname = fileparts(d);
end

basedir = [pname filesep];
runtimedir = [basedir 'runtime' filesep];

if nargin < 1
    pname = uigetdir(basedir, 'Please select the experiment directory...');
    if pname(1) == 0,
        return
    end
    expdir = [pname filesep];
else
    expdir = varargin{1};
    if exist(expdir,'dir') ~= 7;
        pname = uigetdir(basedir, 'Please select the experiment directory...');
        if pname(1) == 0,
            return
        end
        expdir = [pname filesep];
    end
end

MLPrefs.Directories.BaseDirectory = basedir;
MLPrefs.Directories.RunTimeDirectory = runtimedir;
MLPrefs.Directories.ExperimentDirectory = expdir;
setpref('MonkeyLogic', 'Directories', MLPrefs.Directories);
if ispref('MonkeyLogic', 'Directories'),
    success = 1;
end

function tf = isWindowsAdmin()
%ISWINDOWSADMIN True if this user is in admin role.
wi = System.Security.Principal.WindowsIdentity.GetCurrent();
wp = System.Security.Principal.WindowsPrincipal(wi);
tf = wp.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);


