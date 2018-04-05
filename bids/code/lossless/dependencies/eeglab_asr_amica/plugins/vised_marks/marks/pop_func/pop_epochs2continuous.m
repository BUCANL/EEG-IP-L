function [EEG,com]=pop_epochs2continuous(EEG)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_epochs2continuous;
	return;
end;	


% create the string command
% -------------------------
com = ['EEG = pop_epochs2continuous(EEG);'];
exec_com = ['EEG = marks_epochs2continuous(EEG);'];
eval(exec_com)