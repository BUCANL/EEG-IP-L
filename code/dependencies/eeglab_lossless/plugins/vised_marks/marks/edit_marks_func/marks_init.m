function marks_struct = marks_init(datasize,ncomps)

disp('Building initial marks structure...');

if length(datasize)==2;datasize(3)=1;end
marks_struct=[];
%if isfield(EEG,'marks');
%    sprintf('%s/n','Marks structure already exists...');
%else
%    disp('Adding the initial marks structure to EEG...');
    marks_struct=marks_add_label(marks_struct,'time_info',{'manual',[.7,.7,.7],zeros(1,datasize(2),datasize(3))});
    marks_struct=marks_add_label(marks_struct,'chan_info',{'manual',[.7,.7,.7],[.7,.7,.7],-1,zeros(datasize(1),1)});
    if nargin==2;
        marks_struct=marks_add_label(marks_struct,'comp_info',{'manual',[.7,.7,.7],[.7,.7,.7],-1,zeros(ncomps,1)});
    else
        marks_struct=marks_add_label(marks_struct,'comp_info',{'manual',[.7,.7,.7],[.7,.7,.7],-1,[]});
    end
%end
    