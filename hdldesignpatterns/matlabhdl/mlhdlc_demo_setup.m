function varargout = mlhdlc_demo_setup(demoname)
%mlhdlc_demo_setup Create a temporary directory and copy demo files.
%
% mlhdlc_demo_setup('demoname') creates a temporary directory and copies
% all the required files for the demo 'demoname' to the directory. Any
% existing data in the directory will be overwritten.
%
% mlhdlc_demo_setup('list') lists the available demos.

%   Copyright 2013-2023 The MathWorks, Inc.

if nargin ~= 1
    error(['Incorrect number of input arguments. ' ...
        'Use mlhdlc_demo_setup(''demoname'') to copy files to a temporary ' ...
        'directory or mlhdlc_demo_setup(''list'') to get the list of ' ...
        'available demos.']);
end

srcDir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');

if strcmpi(demoname, 'list')
    fileList = dir(fullfile(srcDir, '*_tb.m'));
    demoList = {fileList.name};
    demoList = strrep(demoList.', '_tb', '');
    varargout{1} = cell2table(demoList);
else
    demoPrefix = 'mlhdlc_';

    if ~isempty(regexp(demoname, ['^', demoPrefix], 'once'))
        designName = demoname;
    else
        designName = [demoPrefix, demoname];
    end


    fileList = dir(fullfile(srcDir, [designName, '*.*']));
    if isempty(fileList)
        error('Demo not found. Use mlhdlc_demo_setup(''list'') to get the list of available demos.');
    end

    targetDir = fullfile(tempdir, designName);
    [~,~,~] = rmdir(targetDir);
    [~,~,~] = mkdir(targetDir);
    cd(targetDir);

    for ii = 1:length(fileList)
        copyfile(fullfile(srcDir, fileList(ii).name), pwd, 'f');
    end
end
